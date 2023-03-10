{ config, pkgs }:
{
  nixpkgs.overlays = [ (self: super: {
    iosevka = self.iosevka.override {
      set = "crtschin";
      privateBuildPlan = ''
      [buildPlans.iosevka-crtschin]
      family = "Iosevka Crtschin"
      spacing = "normal"
      serifs = "sans"
      no-cv-ss = true
      export-glyph-names = true

      [buildPlans.iosevka-crtschin.variants]
      inherits = "ss05"

          [buildPlans.iosevka-crtschin.variants.design]
          f = "tailed"
          ascii-single-quote = "straight"

      [buildPlans.iosevka-crtschin.ligations]
      inherits = "dlig"

      [buildPlans.iosevka-crtschin.weights.light]
      shape = 300
      menu = 300
      css = 300

      [buildPlans.iosevka-crtschin.weights.regular]
      shape = 400
      menu = 400
      css = 400

      [buildPlans.iosevka-crtschin.weights.medium]
      shape = 500
      menu = 500
      css = 500

      [buildPlans.iosevka-crtschin.weights.semibold]
      shape = 600
      menu = 600
      css = 600

      [buildPlans.iosevka-crtschin.weights.bold]
      shape = 700
      menu = 700
      css = 700

      [buildPlans.iosevka-crtschin.weights.heavy]
      shape = 900
      menu = 900
      css = 900
      '';
    };
  })];
}
