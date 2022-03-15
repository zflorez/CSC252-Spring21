/*
 * Author: Zachary Florez
 * Course: CSC 252
 * Class: Sim2_HalfAdder 
 * Description: Stimulates a full adder gate with a carryIn bit. 
 * 		Calculates a carryIn plus a plus b and stores values 
 * 		in the sum and the carryOut bit. 
 */ 

public class Sim2_FullAdder {
	
	// Inputs
	public RussWire a, b, carryIn; 

	// Outputs 
	public RussWire sum, carryOut; 

	// OR gate and two Half adder gates 
	private OR orCarry; 
	private Sim2_HalfAdder addAB, addCarry;


	public Sim2_FullAdder(){
		
		// RussWire inputs and outputs
	        a         = new RussWire();
       	        b         = new RussWire();
		carryIn   = new RussWire();
		sum       = new RussWire(); 
		carryOut  = new RussWire(); 
		
		// OR gate 
		orCarry   = new OR();
		
		// Two Half Adders for a Full Adder
		addAB     = new Sim2_HalfAdder(); 
		addCarry  = new Sim2_HalfAdder();
	}
	
	public void execute(){

		// First we half add a and b
		addAB.a.set(a.get());
		addAB.b.set(b.get());
		addAB.execute();

		// Next we half add addAB and the carryIn bit
		// And then store the sum from the sum of the 
		// half adder. 
		addCarry.a.set(addAB.sum.get()); 
		addCarry.b.set(carryIn.get());
		addCarry.execute();
		sum.set(addCarry.sum.get()); 

		// Lastly to calculate if we have a carryOut bit
		// We take the OR or the carryIn from addCarry 
		// and the carryIn from addAB
		orCarry.a.set(addCarry.carry.get()); 
		orCarry.b.set(addAB.carry.get());
		orCarry.execute();
		carryOut.set(orCarry.out.get());	
	}
}

