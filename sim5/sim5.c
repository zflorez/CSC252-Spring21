#include "sim5.h" 
#include <stdio.h> 
#include "sim5_test_commonCode.h"

/*
 * Author: Zachary Florez
 * Course: CSC 252
 * Class: sim5.c
 * Description: This project builds a pipeline processor where each pipeline
 * 		regiser is represented by the desired struct.
 */


/*
 * Get the instruction and set all of the fields out depending on all od the 
 * bits of the instruction. 
 *
 * no return.
 */
void extract_instructionFields(WORD instruction, InstructionFields *fieldsOut)
{

	// Set opcode: bits 31 - 26 (6) 
	fieldsOut -> opcode = ((instruction >> 26) & 0x3f);

	// Set rs: bits 25 - 21 (5) 
	fieldsOut -> rs = ((instruction >> 21) & 0x1f);

	// Set rt: bits 20 - 16 (5)
	fieldsOut -> rt = ((instruction >> 16) & 0x1f);

	// Set rd: bits 15 - 11 (5)
	fieldsOut -> rd = ((instruction >> 11) & 0x1f);

	// Set shamt: bits 10 - 6 (5)
	fieldsOut -> shamt = ((instruction >> 6) & 0x1f);

	// Set funct: bits 5 - 0 (6)
	fieldsOut -> funct = (instruction & 0x3f);

	// Set imm16: bits 15 - 0 (16)
	fieldsOut -> imm16 = (instruction & 0xffff);

	// Set imm32: sign extended imm16
	fieldsOut -> imm32 = signExtend16to32(fieldsOut -> imm16);

	// set address: bits 25 - 0 (26)
	fieldsOut -> address = (instruction & 0x3ffffff);
}



/*
 * In this function we just check if we need a stall or not based off 
 * the current instuctions and the past instructions. 
 *
 * return 1 or 0, depending on if a stall is required or not. 
 */
int IDtoIF_get_stall(InstructionFields *fields, ID_EX  *old_idex, EX_MEM *old_exmem)
{
	// Here we need to check lw instruction 
	if (old_idex -> memRead) {

		// Now we have to check load word is an input 
		// for the next instruction. 
		if (fields -> rs == old_idex -> rt || 
				(old_idex -> rt == fields -> rt && !fields -> opcode)){
			return 1; 
		}
	}

	// Here we need to check sw instructon
	if(old_exmem -> memWrite) {

		if (fields -> rs == old_exmem -> rt) {
			return 1;
		}

		if (fields -> rt == old_idex -> rd || fields -> rt == old_exmem -> rt) {
			return 1;
		}
		 
		// Otherwise there isn't an issue. 
		return 0;
	}

	return 0; 
}


/*
 * This function asks the ID phase if the current instruction needs to perform
 * a branch/jump. We have the parameters Instruction fields and the rsVal, and rtVal 
 * for the current instruction. 
 *
 *
 * retunr 0, 1, 2, or 3. Depending on our values. 
 */
int IDtoIF_get_branchControl(InstructionFields *fields, WORD rsVal, WORD rtVal)
{
	//  Return 1 if operation is beq and true 
	//  Return 1 if operation is bne and true
	if ((fields -> opcode == 0x05 && rsVal != rtVal) || 
	    (fields -> opcode == 0x04 && rsVal == rtVal)) {
		    return 1; 
	}

	// Return 2 if we are jumping to absolute jump destination 
	if (fields -> opcode == 0x02) {
		return 2; 
	}

	// Otherwise we return 0
	return 0; 
}



/*
 * Here we calculate the address we would jump to if we were to 
 * perform a conditional branch (BEQ, BNE). All we need to do is 
 * model a simple branch adder in hardware to calculate the value 
 * on EVERY clock cycle, for EVERY instruction. 
 *
 *
 * return WORD
 */
WORD calc_branchAddr(WORD pcPlus4, InstructionFields *fields)
{
	WORD branchAdder = (fields -> imm32 << 2) +  pcPlus4;
	return branchAdder; 
}



/*
 * Here we go ahead and calculate the address that we would 
 * jump to if we were going to perform a unconditional branch. 
 *
 * This calculates the value every clock cycle, and for every instruction
 * even if there is no possible way that it could be used. 
 *
 * return WORD
 */
WORD calc_jumpAddr(WORD pcPlus4, InstructionFields *fields)
{
	WORD jumpAdder = (fields -> address << 2) | ((pcPlus4 >> 28) << 28);
	return jumpAdder; 
}


/*
 * Function to implement the core of the ID phase. In here we decode 
 * the opcode and funct and then set all the fields of the ID_EX struct
 *
 *
 * Return 1 if we recognixe the opcode/funct.
 * Return 0 if instruction is invalid. 
 */
int execute_ID(int IDstall, InstructionFields *fieldsIn, WORD pcPlus4, 
		WORD rsVal, WORD rtVal, ID_EX *new_idex)
{
	// Set all values that we know will be the same: 
	new_idex -> rs    = fieldsIn -> rs; 
	new_idex -> rt    = fieldsIn -> rt; 
	new_idex -> rd    = fieldsIn -> rd; 
	new_idex -> rsVal = rsVal;
	new_idex -> rtVal = rtVal;
	new_idex -> imm16 = fieldsIn -> imm16; 
	new_idex -> imm32 = fieldsIn -> imm32; 
	
	WORD opcode = fieldsIn -> opcode; 
	WORD funct = fieldsIn -> funct;
	
	// Set to zero initially to save code space. 
	new_idex -> extra1      = 0;
	new_idex -> extra2      = 0; 
	new_idex -> extra3      = 0;
        new_idex -> ALUsrc      = 0; 
	new_idex -> ALU.bNegate = 0;
	new_idex -> ALU.op      = 0; 
	new_idex -> memRead     = 0;
	new_idex -> memWrite    = 0; 
	new_idex -> memToReg    = 0;
	new_idex -> regDst      = 0;
	new_idex -> regWrite    = 0; 	

	// First we check if we have a stall 
	if (IDstall) {
		setStall(new_idex);
		return 1; 
	}

	// add funct = 32 && addu funct = 33
	else if (opcode == 0 && (funct == 32 || funct == 33)) {
		new_idex -> ALU.op   = 2;
		new_idex -> regDst   = 1;
		new_idex -> regWrite = 1;
		return 1;
	}

	// sub funct = 34 && subu funct == 35
	else if (opcode == 0 && (funct == 34 || funct == 35)) {
		new_idex -> ALU.bNegate = 1; 
		new_idex -> ALU.op      = 2; 
		new_idex -> regDst      = 1; 
		new_idex -> regWrite    = 1; 
		return 1;
	}

	// addi opcode = 8 && addiu opcode = 9 
	else if (opcode == 8 || opcode == 9) { 
		new_idex -> ALUsrc   = 1;	
		new_idex -> ALU.op   = 2; 
		new_idex -> regWrite = 1;	
		return 1;
	}

	// and funct = 36
	else if (opcode == 0 && funct == 36) {
		new_idex -> regDst   = 1; 
		new_idex -> regWrite = 1;
		return 1;
	}

	// or funct = 37
	else if (opcode == 0 && funct == 37) {
	       new_idex -> ALU.op   = 1; 
	       new_idex -> regDst   = 1; 
	       new_idex -> regWrite = 1;
	       return 1;
	}

	// xor funct = 38
	else if (opcode == 0 && funct == 38) {
		new_idex -> ALU.op   = 4; 
		new_idex -> regWrite = 1;
		new_idex -> regDst   = 1;
		return 1;
	}

	// nor funct = 39
	else if (opcode == 0 && funct == 39) {
		new_idex -> ALU.op   = 1;
		new_idex -> regDst   = 1;
		new_idex -> regWrite = 1; 
		new_idex -> extra1   = 1; 
		return 1;
	}

	// slt funct = 42
	else if (opcode == 0 && funct == 42) {
		new_idex -> ALU.bNegate = 1; 
		new_idex -> ALU.op      = 3; 
		new_idex -> regDst      = 1;
		new_idex -> regWrite    = 1; 
		return 1;
	}

	// stli opcode = 0x0a (10) 
	else if (opcode == 10) {
		new_idex -> ALUsrc      = 1; 
		new_idex -> ALU.bNegate = 1;
	        new_idex -> ALU.op      = 3; 
		new_idex -> regWrite    = 1;	
		return 1;
	}

	// lw opcode = 0x23 (35)
	else if (opcode == 35) {
		new_idex -> ALUsrc   = 1; 
		new_idex -> ALU.op   = 2; 
		new_idex -> memRead  = 1;
		new_idex -> memToReg = 1;
		new_idex -> regWrite = 1; 
		return 1; 
	}

	// sw opcode = 0x2b (43)
	else if (opcode == 43) {
		new_idex -> ALUsrc   = 1; 
		new_idex -> ALU.op   = 2;
		new_idex -> memWrite = 1;
		return 1; 
	}

	// beq opcode = 0x04 (4) 
	else if (opcode == 4) {
		new_idex -> rs    = 0; 
		new_idex -> rt    = 0; 
		new_idex -> rd    = 0;
		new_idex -> rsVal = 0;
		new_idex -> rtVal = 0;
		return 1; 
	}

	// bne opcode = 0x05 (5)
	else if (opcode == 5) {
		new_idex -> extra1 = 1; 
		new_idex -> rs     = 0;
		new_idex -> rt     = 0; 
		new_idex -> rd     = 0; 
		new_idex -> rsVal  = 0;
		new_idex -> rtVal  = 0;
		return 1;
	}

	// j opcde = 0x02 (2)
	else if (opcode == 2) {
		new_idex -> rs    = 0; 
		new_idex -> rt    = 0;
		new_idex -> rd    = 0; 
		new_idex -> rsVal = 0;
		new_idex -> rtVal = 0;
		return 1; 
	}

	// andi opcode = 0x0c (12)
	else if (opcode == 12) {
		new_idex -> ALUsrc = 2;
		new_idex -> regWrite = 1;
		return 1; 
	}

	// ori opcode = 0x0d (13) 
	else if (opcode == 13) {
		new_idex -> ALUsrc   = 2;
		new_idex -> ALU.op   = 1;
		new_idex -> regWrite = 1;
		return 1; 
	}

	// lui opcode = 0x0f (15)
	else if (opcode == 15) {
		new_idex -> ALUsrc   = 2; 
		new_idex -> ALU.op   = 4; 
		new_idex -> regWrite = 1;
		new_idex -> extra2   = 1; 
		return 1; 
	}

	// nop opcode & funct = 0
	else if (opcode == 0 && funct == 0) {
		new_idex -> ALU.op   = 5; 
		new_idex -> regDst   = 1;
		new_idex -> regWrite = 1;
		new_idex -> rs       = 0;
		new_idex -> rt       = 0;
		new_idex -> rd       = 0;
		new_idex -> rsVal    = 0;
		new_idex -> imm16    = 0;
		new_idex -> imm32    = 0; 
		return 1; 
	}

	// If we get here then we did not reach a 
	// opcode/function that was valid. 
	return 0; 
}


/*
 * Helper function called from execute_ID to set a stall. 
 *
 * no return. 
 */
void setStall(ID_EX *new_idex){
	new_idex -> rs          = 0;
	new_idex -> rt          = 0;
	new_idex -> rd          = 0;
	new_idex -> rsVal       = 0;
	new_idex -> rtVal       = 0;
	new_idex -> memRead     = 0; 
	new_idex -> memWrite    = 0;
	new_idex -> memToReg    = 0;
	new_idex -> regDst      = 0;
	new_idex -> regWrite    = 0;
	new_idex -> extra1      = 0;
	new_idex -> extra2      = 0;
	new_idex -> extra3      = 0;
	new_idex -> imm16       = 0;
	new_idex -> imm32       = 0;
	new_idex -> ALUsrc      = 0;
	new_idex -> ALU.op      = 0;
	new_idex -> ALU.bNegate = 0;
}


/*
 * Function to get input 1 for EX phase. Parameters are ID_EX, 
 * EX_MEM, and MEM_WB Pipeline Registers. 
 *
 * return WORD
 */
WORD EX_getALUinput1(ID_EX *in, EX_MEM *old_exMem, MEM_WB *old_memWb)
{
	// First can then check if old_exMem wrote to a register that 
	// is the same address as rs.
	if (old_exMem -> regWrite && old_exMem -> writeReg == in -> rs) 
	{
		//printf("GAVE OLD EX MEM ALU RESULT\n");
		return old_exMem -> aluResult; 
	}

	// Next we can check if old_memWb wrote to a register that is the
	// same address as rs.  
	if (old_memWb -> regWrite && old_memWb -> writeReg == in -> rs){
		//printf("GAVE OLD MEM WB ALU RESULT\n");
		return old_memWb -> aluResult; 
	}


	// Otherwise we can conclude that we can just return rsValue 
	// from ID_EX pipeline register 
	return in -> rsVal; 
}



/*
 * Same function as input 1 but also handles immediate values. 
 *
 * return WORD 
 */
WORD EX_getALUinput2(ID_EX *in, EX_MEM *old_exMem, MEM_WB *old_memWb)
{
	// First we check if it is an IFormat instruction 
	if (in -> ALUsrc == 1) {
		return in -> imm32; 
	}

	// Next we can check if it is either andi/ori 
	if (in -> ALUsrc == 2) {
		return in -> imm16; 
	}


	// Here we make sure if old_exMem wrote to the same register 
	// as rt. 
	if (old_exMem -> regWrite && old_exMem -> writeReg == in -> rt) 
	{
		return old_exMem -> aluResult; 
	}


	// Here we make sure if old_memWb wrote to the same register 
	// as rt. 
	if (old_memWb -> regWrite && old_memWb -> writeReg == in -> rt)
	{
		return old_memWb -> aluResult;
	}

	// Otherwise there is no issue and we can just return the 
	// rtVal
	return in -> rtVal; 
}



/*
 * This function implements the core of the EX phase, has a pointer to 
 * ID/EX pipeline register. There are two WORD inputs and a pointer 
 * to the EX/MEM pipeline register. 
 *
 * In this function we chose between two possible destination registers 
 * either rt or rd depending on the funciton. We also store the chosen 
 * register into writeReg. 
 *
 * no return. 
 */
void execute_EX(ID_EX *in, WORD input1, WORD input2, EX_MEM *new_exMem)
{
	// RegWrite = 1 bit (Write to a reg or not)
	// writeReg = 5 bits (What register to write to)
	
	// First thing we can copy all the rest of the values to our 
	// next pipeline register. 
	
	new_exMem -> rt        = in -> rt; 
	new_exMem -> rtVal     = in -> rtVal; 
	new_exMem -> regWrite  = in -> regWrite; 
	new_exMem -> aluResult = 0;
	new_exMem -> extra1    = in -> extra1; 
	new_exMem -> extra2    = in -> extra2;
	new_exMem -> extra3    = in -> extra3;
	new_exMem -> memToReg  = in -> memToReg;
	new_exMem -> memRead   = in -> memRead; 
	new_exMem -> memWrite  = in -> memWrite; 

	// Next we start off by seeing what type of format so we can see 
	// what register we need to write to. 
	if (in -> ALUsrc == 1) {
		new_exMem -> writeReg = in -> rt; 
	} else {
		if (in -> ALUsrc == 2) {
			new_exMem -> writeReg = in -> rt;
		} else {
			new_exMem -> writeReg = in -> rd; 
		}
	}

	// lui is our extra 2.
	if (in -> extra2) {
		new_exMem -> aluResult = in -> imm16 << 16; 
		return; 
	}

	// Now we check if operation is 3 to set result less than. 
	if (in -> ALU.op == 3) {
		new_exMem -> aluResult = input1 < input2; 
	}

	// If operation is not 3 then we know either it is 
	// and, or, nor, or adding. 
	else { 
		// First in here we need to check bNegate 
		if (in -> ALU.bNegate) {
			input2 *= -1; 
		}

		// OPERATION = 0 (AND)  
		if (in -> ALU.op == 0) {
			new_exMem -> aluResult = input1 & input2; 
		}

		// OPERATION = 1 (OR) 
		if (in -> ALU.op == 1) {
			// extra 1 = NOR
			if (in -> extra1) {
			        new_exMem -> aluResult = ~(input1 | input2);
			}
	 				
			// Otherwise OR 
			else {
				new_exMem -> aluResult = (input1 | input2);
			}
		}

		// OPERATION = 2 (ADD)
		if (in -> ALU.op == 2) {
			new_exMem -> aluResult = input1 + input2;
		}

		// OPERATION = 4 (XOR)
		if (in -> ALU.op == 4) {
			new_exMem -> aluResult = input1 ^ input2;
		}

	} // END ELSE 
}


/*
 * This function works more or less like execute_MEM() from simulation 4. 
 * We can either read or write to memory. One new feature that is implemented 
 * is handling SW data fowarding - that is the value that you write to memory 
 * might come from the MEM/WB register ahead of you. 
 *
 * no return.
 */
void execute_MEM(EX_MEM *in, MEM_WB *old_memWb, WORD *mem, MEM_WB *new_memwb)
{
	// Just like execute EX we can start by copying all 
	// our values over. 
	new_memwb -> extra1    = in -> extra1; 
	new_memwb -> extra2    = in -> extra1; 
	new_memwb -> extra3    = in -> extra3;
	new_memwb -> aluResult = in -> aluResult;
	new_memwb -> writeReg  = in -> writeReg;
	new_memwb -> memToReg  = in -> memToReg;
	new_memwb -> regWrite  = in -> regWrite; 

	// First we check for a sw instruction 
	if (!in -> memToReg) {
		if (in -> memWrite)
			mem[in -> aluResult / 4] = in -> rtVal;

		// Now we set result to zero if it was not 
		// modified.
		new_memwb -> memResult = 0;
	}

	// Other wise we have a lw instruction 
	if (in -> memToReg) {
		new_memwb -> memResult = mem[in -> aluResult / 4];
	}
}



/*
 * This function works more or less like execute_updateRegs() from Simulation 4. 
 * It may update a regiter. 
 *
 * no return. 
 */
void execute_WB (MEM_WB *in, WORD *regs)
{
	// What we do here is check if we are writing 
	// to a register. If we are then we can check if we are then
	// writing from memory or otherwise we will use the 
	// aluResult. 
	

	// regWrite = 1 bit 
	// memToReg = 5 bits
	// aluResult = WORD 
	
	if (in -> regWrite) {
		if (in -> memToReg) {
			regs[in -> writeReg] = in -> memResult; 
		}

		else {
			regs[in -> writeReg] = in -> aluResult; 
		}
	}
}

