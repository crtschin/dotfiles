/* Copyright 2015-2021 Jack Humbert
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include QMK_KEYBOARD_H
#include "muse.h"


enum planck_layers {
  _QWERTY,
  _FILTER,
  _FN,
  _NUM,
  _ADJUST,
  _SPEC
};

enum planck_keycodes {
  QWERTY = SAFE_RANGE,
  COLEMAK,
  DVORAK,
  PLOVER,
  BACKLIT,
  EXT_PLV
};

#define FN    MO(_FN)
#define NUM   MO(_NUM)
#define SPEC  MO(_SPEC)
#define ADJUST  MO(_ADJUST)
// #define RGBLIGHT_LAYERS_RETAIN_VAL

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

/* Qwerty
 * ,-----------------------------------------------------------------------------------.
 * | GEsc |   Q  |   W  |   E  |   R  |   T  |   Y  |   U  |   I  |   O  |   P  | Bksp |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | Tab  |   A  |   S  |   D  |   F  |   G  |   H  |   J  |   K  |   L  |   /  |Enter |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | Shift|   Z  |   X  |   C  |   V  |   B  |   N  |   M  |   ,  |   .  |  Up  |  "   |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | Ctrl | FN   | GUI  | Alt  |NUM   |    Space    |SPEC  | Ctrl | Left | Down |Right |
 * `-----------------------------------------------------------------------------------'
 */
[_QWERTY] = LAYOUT_planck_grid(
    KC_ESC  ,KC_Q    ,KC_W    ,KC_E    ,KC_R    ,KC_T    ,KC_Y   ,KC_U ,KC_I    ,KC_O    ,KC_P    ,KC_BSPC,
    KC_TAB  ,KC_A    ,KC_S    ,KC_D    ,KC_F    ,KC_G    ,KC_H   ,KC_J ,KC_K    ,KC_L    ,KC_SLSH ,KC_ENT ,
    KC_LSFT ,KC_Z    ,KC_X    ,KC_C    ,KC_V    ,KC_B    ,KC_N   ,KC_M ,KC_COMM ,KC_DOT  ,KC_UP   ,KC_QUOT,
    KC_LCTL ,FN      ,KC_LGUI ,KC_LALT ,NUM     ,KC_SPC  ,KC_SPC ,SPEC ,KC_RCTL ,KC_LEFT ,KC_DOWN ,KC_RGHT
),

/* Filter
 * ,-----------------------------------------------------------------------------------.
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | ____ |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | ____ |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | ____ | ____ | ____ | ____ | ____ | ____ | ____ | ____ | XXXX | XXXX | XXXX |
 * `-----------------------------------------------------------------------------------'
 */
[_FILTER] = LAYOUT_planck_grid(
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,_______ ,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,_______ ,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,
    _______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,XXXXXXX ,XXXXXXX ,XXXXXXX
),

/* FN
 * ,-----------------------------------------------------------------------------------.
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX | INS  | DEL  |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX |  [   |  ]   |  {   |  }   | ____ |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | XXXX | XXXX | XXXX | XXXX | XXXX | XXXX |  (   |  )   |  ;   | PGUP |  \   |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | ____ | ____ | ____ | ____ | ____ | ____ | ____ | ____ | MENU | HOME | PGDN | END  |
 * `-----------------------------------------------------------------------------------'
 */
[_FN] = LAYOUT_planck_grid(
    KC_GRV , XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX, XXXXXXX, KC_INSERT,  KC_DEL,
    _______, XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_LBRC, KC_RBRC, KC_LCBR,   KC_RCBR, _______,
    _______, XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_LPRN, KC_RPRN, KC_SCLN,   KC_PGUP, KC_BSLS,
    _______, _______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______, KC_MENU, KC_HOME,   KC_PGDN, KC_END
),

/* NUM
 * ,-----------------------------------------------------------------------------------.
 * |   ~  |   !  |   @  |   #  |   $  |   %  |   ^  |   &  |   *  |   (  |   )  | Bksp |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | Del  |  F1  |  F2  |  F3  |  F4  |  F5  |  F6  |   _  |   +  |   {  |   }  |  |   |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |  F7  |  F8  |  F9  |  F10 |  F11 |  F12 |ISO ~ |ISO | | Home | End  |      |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |      |      |      |      |             |      | Next | Vol- | Vol+ | Play |
 * `-----------------------------------------------------------------------------------'
 */
[_NUM] = LAYOUT_planck_grid(
    KC_GRV  ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_1    ,KC_2    ,KC_3    ,KC_0    ,_______,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_4    ,KC_5    ,KC_6    ,KC_MINS ,KC_EQL ,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_7    ,KC_8    ,KC_9    ,XXXXXXX ,XXXXXXX,
    _______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,XXXXXXX ,XXXXXXX ,XXXXXXX
),

/* Adjust (NUM + FN)
 *                      v------------------------RGB CONTROL--------------------v
 * ,-----------------------------------------------------------------------------------.
 * |      | Reset|Debug | RGB  |RGBMOD| HUE+ | HUE- | SAT+ | SAT- |BRGTH+|BRGTH-|  Del |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |      |MUSmod|Aud on|Audoff|AGnorm|AGswap|Qwerty|Colemk|Dvorak|Plover|      |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |Voice-|Voice+|Mus on|Musoff|MIDIon|MIDIof|TermOn|TermOf|      |      |      |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |      |      |      |      |             |      |      |      |      |      |
 * `-----------------------------------------------------------------------------------'
 */
[_ADJUST] = LAYOUT_planck_grid(
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_F1    ,KC_F2    ,KC_F3    ,KC_F10,_______,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_F4    ,KC_F5    ,KC_F6    ,KC_F11,_______,
    _______ ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,KC_F7    ,KC_F8    ,KC_F9    ,KC_F12,XXXXXXX,
    _______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,XXXXXXX ,XXXXXXX  ,XXXXXXX
),

/* SPEC
 * ,-----------------------------------------------------------------------------------.
 * |   `  |   1  |   2  |   3  |   4  |   5  |   6  |   7  |   8  |   9  |   0  | Bksp |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * | Del  |  F1  |  F2  |  F3  |  F4  |  F5  |  F6  |   -  |   =  |   [  |   ]  |  \   |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |  F7  |  F8  |  F9  |  F10 |  F11 |  F12 |ISO # |ISO / |Pg Up |Pg Dn |      |
 * |------+------+------+------+------+------+------+------+------+------+------+------|
 * |      |      |      |      |      |      |      |      | Next | Vol- | Vol+ | Play |
 * `-----------------------------------------------------------------------------------'
 */
[_SPEC] = LAYOUT_planck_grid(
    _______ ,RGB_TOG ,RGB_HUI ,CK_TOGG ,CK_UP   ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,_______ ,
    _______ ,RGB_MOD ,RGB_SAI ,CK_RST  ,CK_DOWN ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,_______ ,
    _______ ,RGB_RMOD,RGB_VAI ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,XXXXXXX ,
    _______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,_______ ,XXXXXXX ,XXXXXXX ,XXXXXXX
)

};

// LIGHTING LAYERS
#ifdef RGBLIGHT_LAYERS_RETAIN_VAL
const rgblight_segment_t PROGMEM default_lighting_layer[] = RGBLIGHT_LAYER_SEGMENTS();
const rgblight_segment_t PROGMEM fn_lighting_layer[] = RGBLIGHT_LAYER_SEGMENTS(
    {0, 5, HSV_RED},
);
const rgblight_segment_t PROGMEM num_lighting_layer[] = RGBLIGHT_LAYER_SEGMENTS(
    {0, 5, HSV_BLUE}
);
const rgblight_segment_t PROGMEM adjust_lighting_layer[] = RGBLIGHT_LAYER_SEGMENTS(
    {0, 5, HSV_PURPLE}
);
const rgblight_segment_t PROGMEM spec_lighting_layer[] = RGBLIGHT_LAYER_SEGMENTS(
    {0, 1, HSV_YELLOW},
    {5, 4, HSV_YELLOW}
);
const rgblight_segment_t* const PROGMEM my_rgb_layers[] = RGBLIGHT_LAYERS_LIST(
  default_lighting_layer,
  fn_lighting_layer,
  num_lighting_layer,
  adjust_lighting_layer,
  spec_lighting_layer
);
#endif

void keyboard_post_init_user(void) {
    // Enable the LED layers
#ifdef RGBLIGHT_LAYERS_RETAIN_VAL
    rgblight_layers = my_rgb_layers;
#endif
}

#ifdef AUDIO_ENABLE
  float plover_song[][2]     = SONG(PLOVER_SOUND);
  float plover_gb_song[][2]  = SONG(PLOVER_GOODBYE_SOUND);
#endif

layer_state_t layer_state_set_user(layer_state_t state) {
  layer_state_t state_ = update_tri_layer_state(state, _FN, _NUM, _ADJUST);
#ifdef RGBLIGHT_LAYERS_RETAIN_VAL
  rgblight_set_layer_state(1, layer_state_cmp(state_, _FN));
  rgblight_set_layer_state(2, layer_state_cmp(state_, _NUM));
  rgblight_set_layer_state(3, layer_state_cmp(state_, _ADJUST));
#endif
  return state_;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case QWERTY:
      if (record->event.pressed) {
        print("mode just switched to qwerty and this is a huge string\n");
        set_single_persistent_default_layer(_QWERTY);
      }
      return false;
      break;
    // case BACKLIT:
    //   if (record->event.pressed) {
    //     register_code(KC_RSFT);
    //     #ifdef BACKLIGHT_ENABLE
    //       backlight_step();
    //     #endif
    //     #ifdef KEYBOARD_planck_rev5
    //       writePinLow(E6);
    //     #endif
    //   } else {
    //     unregister_code(KC_RSFT);
    //     #ifdef KEYBOARD_planck_rev5
    //       writePinHigh(E6);
    //     #endif
    //   }
    //   return false;
    //   break;
    // case PLOVER:
    //   if (record->event.pressed) {
    //     #ifdef AUDIO_ENABLE
    //       stop_all_notes();
    //       PLAY_SONG(plover_song);
    //     #endif
    //     layer_off(_SPEC);
    //     layer_off(_NUM);
    //     layer_off(_ADJUST);
    //     layer_on(_PLOVER);
    //     if (!eeconfig_is_enabled()) {
    //         eeconfig_init();
    //     }
    //     keymap_config.raw = eeconfig_read_keymap();
    //     keymap_config.nkro = 1;
    //     eeconfig_update_keymap(keymap_config.raw);
    //   }
    //   return false;
    //   break;
    // case EXT_PLV:
    //   if (record->event.pressed) {
    //     #ifdef AUDIO_ENABLE
    //       PLAY_SONG(plover_gb_song);
    //     #endif
    //     layer_off(_PLOVER);
    //   }
    //   return false;
    //   break;
  }
  return true;
}

bool muse_mode = false;
uint8_t last_muse_note = 0;
uint16_t muse_counter = 0;
uint8_t muse_offset = 70;
uint16_t muse_tempo = 50;

bool encoder_update_user(uint8_t index, bool clockwise) {
  if (muse_mode) {
    if (IS_LAYER_ON(_SPEC)) {
      if (clockwise) {
        muse_offset++;
      } else {
        muse_offset--;
      }
    } else {
      if (clockwise) {
        muse_tempo+=1;
      } else {
        muse_tempo-=1;
      }
    }
  } else {
    if (clockwise) {
      #ifdef MOUSEKEY_ENABLE
        tap_code(KC_MS_WH_DOWN);
      #else
        tap_code(KC_PGDN);
      #endif
    } else {
      #ifdef MOUSEKEY_ENABLE
        tap_code(KC_MS_WH_UP);
      #else
        tap_code(KC_PGUP);
      #endif
    }
  }
    return true;
}

bool dip_switch_update_user(uint8_t index, bool active) {
    switch (index) {
        case 0: {
#ifdef AUDIO_ENABLE
            static bool play_sound = false;
#endif
            if (active) {
#ifdef AUDIO_ENABLE
                if (play_sound) { PLAY_SONG(plover_song); }
#endif
                layer_on(_ADJUST);
            } else {
#ifdef AUDIO_ENABLE
                if (play_sound) { PLAY_SONG(plover_gb_song); }
#endif
                layer_off(_ADJUST);
            }
#ifdef AUDIO_ENABLE
            play_sound = true;
#endif
            break;
        }
        case 1:
            if (active) {
                muse_mode = true;
            } else {
                muse_mode = false;
            }
    }
    return true;
}

void matrix_scan_user(void) {
#ifdef AUDIO_ENABLE
    if (muse_mode) {
        if (muse_counter == 0) {
            uint8_t muse_note = muse_offset + SCALE[muse_clock_pulse()];
            if (muse_note != last_muse_note) {
                stop_note(compute_freq_for_midi_note(last_muse_note));
                play_note(compute_freq_for_midi_note(muse_note), 0xF);
                last_muse_note = muse_note;
            }
        }
        muse_counter = (muse_counter + 1) % muse_tempo;
    } else {
        if (muse_counter) {
            stop_all_notes();
            muse_counter = 0;
        }
    }
#endif
}

bool music_mask_user(uint16_t keycode) {
  switch (keycode) {
    case SPEC:
    case NUM:
      return false;
    default:
      return true;
  }
}
