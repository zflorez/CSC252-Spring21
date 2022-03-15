#include "sim4.h"
#include <stdio.h>


//
// Author:      Zachary Florez
// Course:      CSC 252
// Class:       sim4.c
// Description: This class implements a single-cycle CPU. We are trying to understand 
// 		how the control bits are used to direct the rest of the processor. 


/* This fucntion passes a curPC as an input and a pointer to the WORD array 
 * instruction memory. Since the curPC is a byte we have to divide the curPC 
 * by 4 to get the correct insturction. 
 */
WORD getInstruction(WORD curPC, WORD *instructionMemory)
{
	return instructionMemory[curPC/4];
}


/*
 * This function passes instruction as an input. It then goes through and reads 
 * all of the fields out of the instruction and store them into the fields in 
 * the InstructionFields struct. 
 */
void extract_instructionFields(WORD instruction, InstructionFields *fieldsOut)
{
	// Set opcode: bits 31 - 26 
	fieldsOut -> opcode = ((instruction >> 26) & 0x3f);
	
	// Set rs: bits 25-21 (5)
	fieldsOut -> rs = ((instruction >> 21) & 0x1f);
		
	// Set rt: bits 20-16 (5)
	fieldsOut -> rt = ((instruction >> 16) & 0x1f);
	
	// Set rd: bits 15-11 (5)
	fieldsOut -> rd = ((instruction >> 11) & 0x1f);
	
	// Set shamt: bits 10-6 (5)
	fieldsOut -> shamt = ((instruction >> 6) & 0x1f);
	
	// Set funct: bits 5-0 (6)
	fieldsOut -> funct = (instruction & 0x3f);
	
	// Set imm16: bits 15-0 (16)
	fieldsOut -> imm16 = (instruction & 0xffff);
	
	// Set imm32: Sign extended imm16
	fieldsOut -> imm32 = signExtend16to32(fieldsOut -> imm16);
	
	// Set address: bits 25-0 (26)
	fieldsOut -> address = (instruction & 0x3ffffff);
}

/* This function reads the opcode and from the InstructionFields input 
 * and then depending on the opcode it sets all of the fields for the CPU
 * control. If the instruction is recognized and zero if the opcode 
 * and the function is invalid. 
 */
int fill_CPUControl(InstructionFields *fields, CPUControl *controlOut)
{
	// First read the opcode in from fields. 
	int opcode = fields -> opcode; 	

	// Check if the opcode is a r format instruction
	if (opcode == 0)
	{
		int function = fields -> funct; 
		int valid = fill_CPUControlRFormat(function, controlOut);
		return valid;
	}
	
	// Next check to see if we have a j format instruction. 
	else if (opcode == 2)
	{
		controlOut -> ALUsrc      = 0;
		controlOut -> ALU.op      = 0;
		controlOut -> memRead     = 0;
		controlOut -> memWrite    = 0;
		controlOut -> memToReg    = 0;
		controlOut -> regDst      = 0;
		controlOut -> regWrite    = 0;
		controlOut -> ALU.bNegate = 0;
		controlOut -> branch      = 0;
		controlOut -> jump        = 1;
		return 1;
	}

	// Now check if the opcode is a i format instruction. 
	else if (opcode == 8  || opcode == 9 || opcode == 35 ||
		 opcode == 43 || opcode == 4 || opcode == 10 || 
		 opcode == 15 || opcode == 13)
	{
		int valid = fill_CPUControlIFormat(opcode, controlOut);
		return valid;	
	}
	
	// Other wise the instruction isn't valid that we're 
	// looking at. 
	else 
	{
		return 0;
	}
}

/* 
 * Method that is called once we realize that we have a r format 
 * instuction and now we have to check what type of funct it is
 * to set all of our correct control bits. 
 */
int fill_CPUControlRFormat(int funct, CPUControl *controlOut)
{
	// initially set them all control bits to zero 
	// and then change the onces we actually want to
	// depending on the specific function that we are using.
	controlOut -> jump        = 0;
	controlOut -> ALU.bNegate = 0;
	controlOut -> branch      = 0;
	controlOut -> ALU.op      = 0;
	controlOut -> memRead     = 0;
	controlOut -> memWrite    = 0;
	controlOut -> memToReg    = 0;
	controlOut -> regDst      = 0;
	controlOut -> regWrite    = 0;
	controlOut -> ALUsrc      = 0;
	
	// add - funct: 32 
	if (funct == 32)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.op = 2;
		return 1;
	}
	// addu - funct: 33
	if (funct == 33)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.op = 2;
		return 1;
	}
	// sub - funct: 34 or subu - funct = 35
	if (funct == 34 || funct == 35)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.op      = 2; 
		controlOut -> ALU.bNegate = 1;
		return 1;
	}
	// and - fucnt: 36
	if (funct == 36)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		return 1;
	}
	// or - funct: 37
	if (funct == 37)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.op = 1;
		return 1;
	}
	// xor - funct: 38
	if (funct == 38)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.op = 4;
		return 1;
	}
	// slt - funct: 42
	if (funct == 42)
	{
		controlOut -> regDst      = 1;
		controlOut -> regWrite    = 1;
		controlOut -> ALU.bNegate = 1;
		controlOut -> ALU.op      = 3;
		return 1;
	}
	// srl - func: 2
	if (funct == 2)
	{
		controlOut -> regDst     = 1;
		controlOut -> regWrite   = 1;
		controlOut -> ALU.op     = 1;
		return 1;
	} else {
		return 0;
	}	
}

/* 
 * Helper function that is called inside fill_CPUControl for an I Format 
 * instructions. No return 
 */
int fill_CPUControlIFormat(int opcode, CPUControl *controlOut)
{

	// For all i format instructions instead of setting everything for every
	// different instruction, lets just set everything to zero initially 
	// and then set only things we care about in the specific type of instructions.
	controlOut -> jump        = 0;
	controlOut -> ALU.bNegate = 0;
	controlOut -> branch      = 0;
	controlOut -> ALU.op      = 0;
	controlOut -> memRead     = 0;
	controlOut -> memWrite    = 0;
	controlOut -> memToReg    = 0;
	controlOut -> regDst      = 0;
	controlOut -> regWrite    = 0;

	// opcode for addi || addiu : 8 or 9 
	if (opcode == 8|| opcode == 9)
	{
		controlOut -> ALUsrc   = 1;
		controlOut -> ALU.op   = 2;
		controlOut -> regWrite = 1;
		return 1;
	}


	// opcode for lw: 100011
	if (opcode == 35)
	{
		controlOut -> ALU.op   = 2;
		controlOut -> ALUsrc   = 1;
		controlOut -> memRead  = 1; 
		controlOut -> memToReg = 1;
		controlOut -> regWrite = 1;
		return 1;
	}
	// opcode for sw: 101011  
	if (opcode == 43)
	{
		controlOut -> ALU.op   = 2;
		controlOut -> ALUsrc   = 1;  
		controlOut -> memWrite = 1;
		return 1;
	}

	// opcode for beq: 4
	if (opcode == 4)
	{
		controlOut -> ALU.op      = 2;
		controlOut -> ALU.bNegate = 1;
		controlOut -> ALUsrc      = 0;
		controlOut -> branch      = 1;
		return 1;
	}

	// opcode for slti: 1010
	if (opcode == 10)
	{
		controlOut -> ALUsrc       = 1;
		controlOut -> ALU.op       = 3;
		controlOut -> regWrite     = 1;
		controlOut -> ALU.bNegate  = 1;
		return 1;
	}

	// lui extra instruction: 15
	if (opcode == 15)
	{
		controlOut -> regWrite = 1;
		return 1;
	}

	if (opcode == 13){
		controlOut -> regWrite = 1;
		controlOut -> ALUsrc   = 1;
		controlOut -> ALU.op   = 1;
		return 1;
	}

	return 0;
}

/* 
 * Sets the first input for the ALU, it will always be the rsVal 
 * so we just return that here. 
 */
WORD getALUinput1(CPUControl *controlIn, InstructionFields *fieldsIn,
		  WORD rsVal, WORD rtVal, WORD reg32, WORD reg33, 
		  WORD oldPC)
{
	return rsVal;
}

/* 
 * Sets the second inout for the ALU, here the second value depends 
 * on the ALUsrc for the inputted instruction. We either return the 
 * rtVal or the immediate 32 bit field to be set. 
 */
WORD getALUinput2(CPUControl *controlIn, InstructionFields *fieldsIn, 
		  WORD rsVal, WORD rtVal, WORD reg32, WORD reg33, 
		  WORD oldPC)
{
	// R Format Instruction
	if (controlIn -> ALUsrc == 0)
	{
		return rtVal; 
	} 
	
	// Not a R Format 
	else
	{
		if (fieldsIn -> opcode == 13)
			return fieldsIn -> imm32 | fieldsIn -> imm16 << 16;
		return fieldsIn -> imm32; 
	}	
}

/* 
 * This function implements the ALU and seta the output to the 
 * value inside aluResultOut and the zero output always because 
 * we have to set it to something even if it doesn't matter.
 */
void execute_ALU(CPUControl *controlIn, WORD input1, WORD input2, 
		 ALUResult *aluResultOut)
{
	// Use addition and subtraction operations. 
	// We know what we want to do by looking at the ALU.op 
	// inside the control fields. 
	
	// ALUop = 0 means we're doing additon. 
	int operation = controlIn -> ALU.op;

	//printf("OPERATION ================ %d\n", operation);
	//printf("INPUT1    ================ %d\n", input1);
	//printf("INPUT2    ================ %d\n", input2);
	
	// ADD & SUB Operation
	if (operation == 2)
	{
		if (controlIn -> ALU.bNegate == 1)
		{
			aluResultOut -> result = input1 - input2; 
		} else {
			int sum = input1 + input2; 
			aluResultOut -> result  = sum;
		}
	} 
	
	// AND Operation
	else if (operation == 0)
	{
		aluResultOut -> result = input1 & input2; 
		aluResultOut -> zero = 0;
	}
	
	// OR operation
	else if (operation == 1)
	{
		aluResultOut -> result = input1 | input2;
		aluResultOut -> zero = 0;
	}

	// SLT Operation
	else if (operation == 3)
	{
		aluResultOut -> result = 0;

		if (input1 < input2)
		{
			aluResultOut -> zero   = 0;	
			aluResultOut -> result = 1;
		}
		else
		{	
			aluResultOut -> zero   = 1;
		        aluResultOut -> result = 0;
		}
	}
	
	// XOR Operation
	else if (operation == 4)
	{
		aluResultOut -> result = input1 ^ input2; 
	}
}

/* 
 * This function implements the data memory unit. controlIn is the 
 * CPUControl. What we do basically is check control bits and either 
 * set values.
 */
void execute_MEM(CPUControl *controlIn, ALUResult *aluResultIn, 
		 WORD rsVal, WORD rtVal, WORD *memory, 
		 MemResult *resultOut)
{
	// First we have check our memory control bits 
	// inside our CPU control to see exactly what 
	// we want to do, other wise we set all our wires 
	// to false. 
	
	int immediate = aluResultIn -> result;
	// First check memRead
	if (controlIn -> memRead == 1)
		resultOut -> readVal = memory[immediate / 4];
	if (controlIn -> memRead == 0) 
		resultOut -> readVal = 0;

	// Now check memWrite
	if (controlIn -> memWrite == 1)
		memory[immediate / 4] = rtVal ; 
}

/*
 * This function implements the logic which decides what the next 
 * PC would be and returns it.  
 */
WORD getNextPC(InstructionFields *fields, CPUControl *controlIn, int aluZero, 
	       WORD rsVal, WORD rtVal, WORD oldPC)
{
	// First check whatnt immediate = aluResultIn -> result;
	//
	// increment by 4 bytes (4 * 8) 
	if (fields -> opcode == 2)
	{
		int newPC = oldPC + 4;
		int newAddress = fields -> address << 2; 
		int bit_31_28  = (newPC & 0xF0000000);
		int nextPC     = bit_31_28 | newAddress;
		return nextPC;
	}
	return oldPC + 4;
}

void execute_updateRegs(InstructionFields *fields, CPUControl *controlIn,
		        ALUResult *aluResultIn, MemResult *memResultIn, 
			WORD *regs)
{
	// Check how to write back to register.
	if (controlIn -> regWrite == 1)
	{
		// Now we check what type of instruction it was 
		// to see where we get the value to write back 
		// from.

	        // R Format, write back to rd register (
		if (fields -> funct == 2)
			regs[fields -> rd] = regs[fields -> rt] >> fields -> shamt;	
		if (fields -> opcode == 0)
		 	regs[fields -> rd] = aluResultIn -> result;
	       // load word opcode = 35	
		else if (fields -> opcode == 35)
			regs[fields -> rt] = aluResultIn -> result; 
		// addi and addiu 
		else if (fields -> opcode == 8 || fields -> opcode == 9)
			regs[fields -> rt] = aluResultIn -> result;
		//slti
		else if (fields -> opcode == 10)
			regs[fields -> rt] = aluResultIn -> result;
	       // lui opcode = 15	
		else if (fields -> opcode == 15)
			regs[fields -> rt] = fields -> imm16 << 16;
		else if (fields -> opcode == 13){
				regs[fields -> rt] = fields -> imm16 ;
		}
	}	
}


