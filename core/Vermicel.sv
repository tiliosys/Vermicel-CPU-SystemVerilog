//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel processor core.
//
// This is the main module of the Vermicel core.
// It is a wrapper that allows to choose one of these implementations:
// - Verpipeline: a 5-stage pipeline architecture
// - Versequence: an architecture with a state machine as the sequencer.
module Vermicel #(
    parameter bit PIPELINE = 1      // If 1, choose the pipeline architecture.
) (
    Verbus.read_only_request  ibus, // The instruction fetch bus.
    Verbus.read_write_request dbus  // The data access bus.
);

    generate
        if (PIPELINE) begin : gen_pipeline
            Verpipeline core (
                .ibus(ibus),
                .dbus(dbus)
            );
        end
        else begin : gen_sequence
            // The state-machine architecture uses dbus for instructions and data.
            // These instructions disable ibus.
            assign ibus.valid     = 0;
            assign ibus.address   = 0;
            assign ibus.lookahead = 0;

            Versequence core (
                .bus(dbus)
            );
        end
    endgenerate

endmodule


