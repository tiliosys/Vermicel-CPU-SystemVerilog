//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel common data types.
package Verdata_pkg;

    typedef int unsigned      word_t;        // 32-bit unsigned.
    typedef int signed        signed_word_t; // 32-bit signed.
    typedef shortint unsigned half_word_t;   // 16-bit unsigned.
    typedef byte unsigned     byte_t;        // 8-bit unsigned.

    typedef bit[3:0]          wstrobe_t;     // Data bus byte selection.

endpackage

