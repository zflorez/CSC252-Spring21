/* Simulates a physical device that performs (signed) addition on
 * a 32-bit input.
 *
 * Author: Zachary Florez
 * Course: CSC 252
 * Class: Sim1_ADD
 * Description: This class has the fields a, b, sum, carryOut, and overflow. We stimulate
 * 		signed addition on a 32 bit input in this class.  
 */

public class Sim1_ADD
{	
	/*
	 * Executes the function of the class: first here we set values aValue, 
	 * bValue, and carryIn all equal to false. Then we loop through both 
	 * a and b with one for-loop to calculate the sum and carryIn for every 
	 * a-bit plus a b-bit plus a caryIn if there is one. 
	 *
	 * At the end of our for-loop we calculate if there was a overflow that happened 
	 * after our addition. We do this which a bunch of if-statements for these 
	 * specific special cases. 
	 *
	 */
	public void execute()
	{
		// variables to set. 
		boolean aValue = false; 
		boolean bValue = false;
		boolean carryIn = false;

		//Calculating every index for sum for a & b
		for (int i = 0; i < 32; i ++){
			aValue = this.a[i].get(); // boolean 1 or 0 value
			bValue = this.b[i].get(); // boolean 1 or 0 value

			// all conditional statements
			if (aValue == false && bValue == false && carryIn == false){
				// 0 & 0 & 0
				this.sum[i].set(false);
				carryIn = false;
			} else if (aValue == true && bValue == false && carryIn == false){
				// 0 & 1 & 0
				this.sum[i].set(true);
				carryIn = false;
			} else if(aValue == false && bValue == false && carryIn == true){
				// 1 & 0 & 0
				this.sum[i].set(true);
				carryIn = false;
			} else if (aValue == false && bValue == true && carryIn == false){
				// 0 & 0 & 1
				this.sum[i].set(true);
				carryIn = false;
			} else if (aValue == true && bValue == false && carryIn == true){
				// 1 & 1 & 0
				this.sum[i].set(false);
				carryIn = true;
			} else if (aValue == true && bValue == true && carryIn == false){
				// 0 & 1 & 1
				this.sum[i].set(false);
				carryIn = true;
		        } else if (aValue == false && bValue == true && carryIn == true){
				// 1 & 0 & 1
				this.sum[i].set(false);
				carryIn = true;
			} else if (aValue == true && bValue == true && carryIn == true){
				// 1 & 1 & 1
				this.sum[i].set(true);
				carryIn = true;
			}

		}

		// First check after adding the MSB's if there was a carryout.  
		if (carryIn == true){
			carryOut.set(true);
		} else {
			carryOut.set(false);
		}


		// Now we check for an overflow after all that addition. 
		if ( (a[31].get() != b[31].get()) && carryIn == false){
			// if both MSB's do not equal each other and there is no carryIn
			// then there is no overflow. 
			overflow.set(false);
		} else {
			if ( a[31].get() == true && b[31].get() == true && sum[31].get() == true && carryIn == false){
				//if a = 1, b = 1, sum = 1 and carryIn = 0, overflow occurs. 
				overflow.set(true);
			} else if (a[31].get() == true && b[31].get() == true && sum[31].get() == false && carryIn == true){
				//if a = 1, b = 1, sum = 0 and carryIn = 1, overflow occurs. 
				overflow.set(true);
			} else if (a[31].get() == false && b[31].get() == false && sum[31].get() == true && carryIn == false){
				// if a = 0, b = 0, sum = 1,and carryIn = 0, overflow occurs
				overflow.set(true);
			}else if (a[31].get() == false && b[31].get() == false && sum[31].get() == false && carryIn == true){
				// if a = 0, b = 0, sum = 0, and carryIn = 1, overflow occurs.  
				overflow.set(false);
			}
		       	else {
				// if none of the above occurs after addition, then no overflow. 
				overflow.set(false);
			}
		}
	}

	// ------ 
	// It should not be necessary to change anything below this line,
	// although I'm not making a formal requirement that you cannot.
	// ------ 

	// inputs
	public RussWire[] a,b;

	// outputs
	public RussWire[] sum;
	public RussWire   carryOut, overflow;

	public Sim1_ADD()
	{
		/* Instructor's Note:
		 *
		 * In Java, to allocate an array of objects, you need two
		 * steps: you first allocate the array (which is full of null
		 * references), and then a loop which allocates a whole bunch
		 * of individual objects (one at a time), and stores those
		 * objects into the slots of the array.
		 */

		a   = new RussWire[32];
		b   = new RussWire[32];
		sum = new RussWire[32];
		
		// Execute instructors note above with this for-loop. 
		for (int i=0; i<32; i++){
			a  [i] = new RussWire();
			b  [i] = new RussWire();
			sum[i] = new RussWire();
		}

		carryOut = new RussWire();
		overflow = new RussWire();
	}
}

