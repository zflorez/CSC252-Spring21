/*
 * Author: Zachary Florez
 * Course: CSC 252
 * Class: Sim2_XOR 
 * Description: Simulates a XOR gate for two RussWire inputs
 * 		a and b and sets the XOR of a and b to the output. 
 *
 */

public class Sim2_XOR {

	// inputs 
	public RussWire a, b; 
	// outputs
	public RussWire out; 

	// logical operators 
	private AND andInputs, andA, andB, andAll;
        private NOT notInputs, notA, notB, notAll;	

	public void execute(){

		// First we copy our input over into inputs into AND gate.
		// Then make our AND gate and store results into our 
		// NOT gate to set that output 
		andInputs.a.set(a.get());
		andInputs.b.set(b.get());
		andInputs.execute();
		notInputs.in.set(andInputs.out.get());
		notInputs.execute(); 
		
		// Now we have to create a notA value that calculates 
		// (A NAND (A NAND B))
		andA.a.set(a.get());
		andA.b.set(notInputs.out.get());
		andA.execute();
		notA.in.set(andA.out.get()); 
		notA.execute();


		// Now we have to create a notB value that calculates 
		// (B NAND (A NAND B))
		andB.a.set(b.get());
		andB.b.set(notInputs.out.get());
		andB.execute();
		notB.in.set(andB.out.get());
		notB.execute();

		// Now finally we have to create a notAll value that
		// calculates:
		//
		// (A NAND (A NAND B)) NAND (B NAND (A NAND B))
		//
		// which is equal to an XOR gate. 
		andAll.a.set(notA.out.get());
		andAll.b.set(notB.out.get());
		andAll.execute();
		notAll.in.set(andAll.out.get());
		notAll.execute();
		
		// Don't forget to store the final value into the output. 
		out.set(notAll.out.get());

	}

	public Sim2_XOR(){
		
		// RussWire objects
		a         = new RussWire();
		b         = new RussWire();
		out       = new RussWire();
		
		// AND objects
		andInputs = new AND();
		andA      = new AND();
		andB      = new AND();
		andAll    = new AND();

		// NOT objects
		notInputs = new NOT();
		notA      = new NOT();
		notB      = new NOT();
		notAll    = new NOT();
	}	
}

