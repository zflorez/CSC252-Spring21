/*
 * Author: Zachary Florez
 * Course: CSC 252
 * Class: Sim2_HalfAdder 
 * Description: Stimulates a 1 bit adder with a sum and a carryOut
 * 		bit. Does not count for any carry-in bits. 
 *
 */

public class Sim2_HalfAdder {

	// Inputs 
	public RussWire a, b; 

	// Outputs
	public RussWire sum, carry;

	// AND and XOR objects to stimulate the half-adder
	// gate. 
	private AND and; 
	private Sim2_XOR xor;  

	public Sim2_HalfAdder(){
		
		// RussWire objects
		a     = new RussWire();
		b     = new RussWire();
		sum   = new RussWire();
		carry = new RussWire(); 
		
		// AND and XOR objects
		and   = new AND();
		xor   = new Sim2_XOR();

	}

	public void execute(){
		
		// sum bit in a half adder is equal to the 
		// two bits xor'd together. 
		xor.a.set(a.get());
		xor.b.set(b.get());
		xor.execute();
		sum.set(xor.out.get());
		
		// carry out bit in a half adder is equal to the 
		// two bits anded together. 
		and.a.set(a.get());
		and.b.set(b.get());
		and.execute();
		carry.set(and.out.get());
	}



}



