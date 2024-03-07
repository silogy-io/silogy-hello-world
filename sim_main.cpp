// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <getopt.h>
#include <random>
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtop.h"

struct color_t {
  uint16_t red;
  uint64_t green;
  uint16_t blue;
};

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

inline void tick(const std::unique_ptr<Vtop> &tb,
                 const std::unique_ptr<VerilatedContext> &contextp) {
  tb->i_clk = 0;
  tb->eval();
  contextp->timeInc(5);
  tb->i_clk = 1;
  tb->eval();
  contextp->timeInc(5);
}

void reset(const std::unique_ptr<Vtop> &tb,
           const std::unique_ptr<VerilatedContext> &contextp) {
  tb->i_reset_n = 0;
  tick(tb, contextp);
  tb->i_reset_n = 1;
}

inline void sendByte(const std::unique_ptr<Vtop> &tb,
                     const std::unique_ptr<VerilatedContext> &contextp,
                     uint8_t byte) {
  tb->i_TX_Byte = byte;
  tb->i_TX_DV = 1;
  tick(tb, contextp);
  tb->i_TX_DV = 0;
  while (tb->i_TX_DV != 1) {
    tick(tb, contextp);
  }
}

int main(int argc, char **argv) {
  // This is a more complicated example, please also see the simpler
  // examples/make_hello_c.

  // Create logs/ directory in case we have traces to put under it
  Verilated::mkdir("logs");

  // Construct a VerilatedContext to hold simulation time, etc.
  // Multiple modules (made later below with Vtop) may share the same
  // context to share time, or modules may have different contexts if
  // they should be independent from each other.

  // Using unique_ptr is similar to
  // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  // Do not instead make Vtop as a file-scope static variable, as the
  // "C++ static initialization order fiasco" may cause a crash

  // Set debug level, 0 is off, 9 is highest presently used
  // May be overridden by commandArgs argument parsing
  contextp->debug(0);

  // Randomization reset policy
  // May be overridden by commandArgs argument parsing
  contextp->randReset(2);

  // Verilator must compute traced signals
  contextp->traceEverOn(true);

  // Pass arguments so Verilated code can see them, e.g. $value$plusargs
  // This needs to be called before you create any model
  contextp->commandArgs(argc, argv);
  contextp->fatalOnError(false);

  // Construct the Verilated model, from Vtop.h generated from Verilating
  // "top.v". Using unique_ptr is similar to "Vtop* top = new Vtop" then
  // deleting at end. "TOP" will be the hierarchical name of the module.
  const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

  // Set Vtop's input signals
  top->i_reset_n = !0;
  top->i_clk = 0;
  top->i_vga_r = 0x0;
  top->i_vga_g = 0x0;
  top->i_vga_b = 0x0;

  int seed = 0; // default seed value

  static struct option long_options[] = {{"seed", required_argument, 0, 's'},
                                         {0, 0, 0, 0}};

  int option_index = 0;
  int c;

  while ((c = getopt_long(argc, argv, "", long_options, &option_index)) != -1) {
    switch (c) {
    case 's':
      seed = std::atoi(optarg);
      break;
    default: /* '?' */
      // Ignore other command line arguments
      break;
    }
  }

  const uint64_t payload = 248;

  uint8_t datastream[payload];

  std::random_device rd;

  std::mt19937 gen(seed);

  std::uniform_int_distribution<uint8_t> distribution(0, 255);

  VL_PRINTF("Starting off with  seed %d", seed);

  for (int i = 0; i < payload; i++) {
    payload[i] = distribution(gen);

  }

  // Simulate for one screen render
  reset(top, contextp);
  auto prev_cycle_y = 0;
  while (!contextp->gotFinish()) {

    setColor(top, bitmap[top->o_y_addr][top->o_x_addr]);
    tick(top, contextp);
    // Read outputs
    if (prev_cycle_y != top->o_y_addr) {
      VL_PRINTF("[%" PRId64 "] x_addr=%d y_addr=%d\n", contextp->time(),
                top->o_x_addr, top->o_y_addr);
      prev_cycle_y = top->o_y_addr;
    }
  }
  // Final model cleanup
  top->final();
// Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
  Verilated::mkdir("logs");
  contextp->coveragep()->write("logs/coverage.dat");
#endif

  // Return good completion status
  // Don't use exit() or destructor won't get called
  return 0;
}
