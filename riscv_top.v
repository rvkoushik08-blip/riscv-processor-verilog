
`timescale 1ns / 1ps

module riscv_top (
    input wire clk,
    input wire reset,
    output wire [31:0] pc,
    output wire [31:0] instruction
);

  
    wire regWrite;
    wire memRead;
    wire memWrite;
    wire alusrc;
    wire memtoreg;
    wire [3:0] ALUControl;

    
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [31:0] readData1;
    wire [31:0] readData2;
    wire [31:0] writeBackData;

  
    wire [31:0] immediate;

    // ALU signals
    wire [31:0] aluInputB;
    wire [31:0] aluResult;
    wire zero;

    
    wire [31:0] memoryReadData;

    
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

  
    instruction_memory IMEM (
        .pc(pc),
        .instruction(instruction)
    );


    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

  
    control_unit CU (
        .instr(instruction),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .alusrc(alusrc),
        .memtoreg(memtoreg),
        .ALUControl(ALUControl)
    );


    imm_gen IMM (
        .instr(instruction),
        .imm_out(immediate)
    );


    
    register_file RF (
        .clk(clk),
        .reset(reset),
        .regwrite(regWrite),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(writeBackData),
        .read_data1(readData1),
        .read_data2(readData2)
    );


    mux_2_1 MUX_ALU (
        .a(immediate),
        .b(readData2),
        .sel(alusrc),
        .out(aluInputB)
    );

    
    
    alu ALU (
        .a(readData1),
        .b(aluInputB),
        .alu_control(ALUControl),
        .result(aluResult),
        .zero(zero)
    );


    data_memory DMEM (
        .clk(clk),
        .reset(reset),
        .memRead(memRead),
        .memWrite(memWrite),
        .address(aluResult),
        .writeData(readData2),
        .readData(memoryReadData)
    );

   mux_2_1 MUX_WB (
        .a(memoryReadData),
        .b(aluResult),
        .sel(memtoreg),
        .out(writeBackData)
    );

endmodule
