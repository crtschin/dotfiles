from __future__ import annotations

import glob
import os
import re
import subprocess
import sys
from collections import defaultdict
from collections.abc import Generator

import click

VERSION_SUFFIX = re.compile(r"-\d+(\.\d+)*$")
# Matches a package name in build-depends, ignoring version constraints.
# e.g. "base >=4.14 && <5" -> "base", "text" -> "text"
DEP_NAME_RE = re.compile(r"([A-Za-z0-9][-A-Za-z0-9]*)")

# Type aliases
Field = tuple[str, str]
Stanza = tuple[str, str | None, list[Field]]

STANZA_RE = re.compile(
    r"^(common|library|executable|test-suite|benchmark|source-repository|flag|foreign-library)(?:\s+(.+))?$",
    re.IGNORECASE,
)


def strip_version(pkg_id: str) -> str:
    """Remove version suffix from a package id like 'base-4.18.0.0' -> 'base'."""
    m = VERSION_SUFFIX.search(pkg_id)
    return pkg_id[: m.start()] if m else pkg_id


def run_ghc_pkg(args: list[str], package_db: str | None = None) -> str:
    cmd: list[str] = ["ghc-pkg"]
    if package_db:
        cmd += ["--package-db", package_db]
    cmd += args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    except FileNotFoundError:
        click.echo("error: ghc-pkg not found on PATH", err=True)
        click.echo(
            "Run this inside a Haskell dev shell where GHC is available.",
            err=True,
        )
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        stderr: str = str(e.stderr) if e.stderr is not None else ""  # pyright: ignore[reportAny]
        click.echo(f"error: ghc-pkg failed: {stderr}", err=True)
        sys.exit(1)
    return result.stdout


def build_ghcpkg_graph(
    package_db: str | None = None,
) -> defaultdict[str, set[str]]:
    """Build adjacency list {pkg_name: set(dep_name)} from ghc-pkg."""
    raw = run_ghc_pkg(["field", "*", "name,depends"], package_db)

    graph: defaultdict[str, set[str]] = defaultdict(set)
    known: set[str] = set()
    current_name: str | None = None

    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("name:"):
            current_name = line.split(":", 1)[1].strip()
            known.add(current_name)
        elif line.startswith("depends:"):
            deps_raw = line.split(":", 1)[1].strip()
            if current_name and deps_raw:
                for dep_id in deps_raw.split():
                    dep_name = strip_version(dep_id)
                    graph[current_name].add(dep_name)

    for pkg in known:
        _ = graph.setdefault(pkg, set())

    return graph


# -- .cabal file parsing --


def _parse_fields(content_lines: list[str]) -> list[Field]:
    """Parse indentation-based fields from a list of content lines."""
    fields: list[Field] = []
    i = 0
    while i < len(content_lines):
        line = content_lines[i]

        # Check if it looks like a field: "field-name: value"
        field_match = re.match(r"^(\s*)([-A-Za-z0-9]+)\s*:\s*(.*)", line)
        if field_match:
            field_indent = len(field_match.group(1))
            fname = field_match.group(2).lower()
            fval = field_match.group(3).strip()
            # Collect continuation lines (more indented than the field name)
            i += 1
            while i < len(content_lines):
                next_line = content_lines[i]
                next_stripped = next_line.strip()
                if not next_stripped:
                    i += 1
                    continue
                next_indent = len(next_line) - len(next_line.lstrip())
                if next_indent > field_indent:
                    # Continuation
                    if fval:
                        fval += " " + next_stripped
                    else:
                        fval = next_stripped
                    i += 1
                else:
                    break
            fields.append((fname, fval))
        else:
            i += 1

    return fields


def parse_cabal_sections(text: str) -> tuple[list[Field], list[Stanza]]:
    """Parse a .cabal file into top-level fields and stanzas.

    Returns (top_level_fields, stanzas) where:
      top_level_fields: list of (field_name, field_value) at the top level
      stanzas: list of (stanza_type, stanza_name_or_None, fields)
               where fields is list of (field_name, field_value)

    Field values include continuation lines joined with spaces.
    """
    lines = text.splitlines()
    sections: list[tuple[tuple[str, str | None] | None, list[str]]] = []
    current_header: tuple[str, str | None] | None = None
    current_lines: list[str] = []

    for line in lines:
        stripped = line.strip()
        # Skip blank lines and comments
        if not stripped or stripped.startswith("--"):
            continue

        # Check if this is a stanza header (not indented)
        if line[0:1] not in (" ", "\t"):
            m = STANZA_RE.match(stripped)
            if m:
                # Save previous section
                sections.append((current_header, current_lines))
                current_header = (m.group(1).lower(), m.group(2))
                current_lines = []
                continue

        current_lines.append(line)

    sections.append((current_header, current_lines))

    top_fields: list[Field] = []
    stanzas: list[Stanza] = []
    for header, content in sections:
        fields = _parse_fields(content)
        if header is None:
            top_fields = fields
        else:
            stype, sname = header
            stanzas.append((stype, sname, fields))

    return top_fields, stanzas


def extract_dep_names(build_depends_value: str) -> set[str]:
    """Extract package names from a build-depends value string.

    e.g. "base >=4.14 && <5, text, aeson >= 2.0" -> {"base", "text", "aeson"}
    """
    deps: set[str] = set()
    for chunk in build_depends_value.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        m = DEP_NAME_RE.match(chunk)
        if m:
            deps.add(m.group(1))
    return deps


def resolve_imports(
    stanza_fields: list[Field],
    common_stanzas: dict[str, list[Field]],
    visited: set[str] | None = None,
) -> set[str]:
    """Resolve all build-depends for a stanza, including imported common stanzas.

    common_stanzas: dict {name: fields_list}
    Returns set of dependency package names.
    """
    if visited is None:
        visited = set()

    deps: set[str] = set()
    for fname, fval in stanza_fields:
        if fname == "build-depends":
            deps |= extract_dep_names(fval)
        elif fname == "import":
            for imp_name in fval.split(","):
                imp_name = imp_name.strip()
                if imp_name and imp_name not in visited:
                    visited.add(imp_name)
                    if imp_name in common_stanzas:
                        deps |= resolve_imports(
                            common_stanzas[imp_name], common_stanzas, visited
                        )
    return deps


def parse_cabal_file(filepath: str) -> tuple[str | None, set[str]]:
    """Parse a .cabal file, return (package_name, set_of_dep_names)."""
    with open(filepath) as f:
        text = f.read()

    top_fields, stanzas = parse_cabal_sections(text)

    # Get package name
    pkg_name: str | None = None
    for fname, fval in top_fields:
        if fname == "name":
            pkg_name = fval.strip()
            break

    if not pkg_name:
        return None, set()

    # Collect common stanzas
    common_stanzas: dict[str, list[Field]] = {}
    for stype, sname, fields in stanzas:
        if stype == "common" and sname:
            common_stanzas[sname.strip()] = fields

    # Collect all deps from top-level and all stanzas
    all_deps: set[str] = set()

    # Top-level build-depends (rare but valid)
    all_deps |= resolve_imports(top_fields, common_stanzas)

    # All component stanzas
    for stype, _sname, fields in stanzas:
        if stype != "common":
            all_deps |= resolve_imports(fields, common_stanzas)

    # Remove self-dependency if present
    all_deps.discard(pkg_name)

    return pkg_name, all_deps


def find_cabal_files(project_dir: str) -> list[str]:
    """Find all .cabal files in a project directory (non-recursive)."""
    return glob.glob(os.path.join(project_dir, "*.cabal"))


# -- Graph search --


def find_all_paths(
    graph: defaultdict[str, set[str]], source: str, target: str
) -> Generator[list[str], None, None]:
    """Yield all simple paths from source to target via DFS."""
    stack: list[tuple[str, list[str]]] = [(source, [source])]
    while stack:
        node, path = stack.pop()
        if node == target:
            yield path
            continue
        for neighbor in sorted(graph.get(node, [])):
            if neighbor not in path:
                stack.append((neighbor, path + [neighbor]))


@click.command()
@click.argument("source")
@click.argument("target")
@click.option(
    "--package-db",
    default=None,
    help="Path to a GHC package database (optional, uses default if omitted).",
)
@click.option(
    "--project-dir",
    default=".",
    help="Directory containing .cabal files to include in the graph.",
    type=click.Path(exists=True, file_okay=False),
)
def main(
    source: str,
    target: str,
    package_db: str | None,
    project_dir: str,
) -> None:
    """Find all dependency paths from SOURCE to TARGET.

    Uses ghc-pkg for the installed package graph and parses local .cabal
    files (with common stanza support) to include the current project.
    """
    graph = build_ghcpkg_graph(package_db)

    # Merge local .cabal packages into the graph
    cabal_files = find_cabal_files(project_dir)
    for cf in cabal_files:
        pkg_name, deps = parse_cabal_file(cf)
        if pkg_name:
            graph[pkg_name] |= deps
            click.echo(
                f"Loaded local package '{pkg_name}' from {cf} ({len(deps)} deps)",
                err=True,
            )

    if source not in graph:
        click.echo(f"error: package '{source}' not found", err=True)
        available = sorted(k for k in graph if k.startswith(source[:3]))
        if available:
            click.echo(
                f"hint: similar packages: {', '.join(available[:10])}",
                err=True,
            )
        sys.exit(1)

    if target not in graph:
        click.echo(f"error: package '{target}' not found", err=True)
        available = sorted(k for k in graph if k.startswith(target[:3]))
        if available:
            click.echo(
                f"hint: similar packages: {', '.join(available[:10])}",
                err=True,
            )
        sys.exit(1)

    count = 0
    for path in find_all_paths(graph, source, target):
        click.echo(" -> ".join(path))
        count += 1

    if count == 0:
        click.echo(
            f"No dependency paths found from '{source}' to '{target}'.",
            err=True,
        )
        sys.exit(1)
    else:
        click.echo(f"\n{count} path(s) found.", err=True)


main()
