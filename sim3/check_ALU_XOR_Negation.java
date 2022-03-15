public class check_ALU_XOR_Negation {
	
	public static void main(String[] args) {
			
			Sim3_ALU x = new Sim3_ALU(11);
			
			x.bNegate.set(true);
			
			x.a[0].set(false);
			x.a[1].set(false);
			x.a[2].set(false);
			x.a[3].set(true);
			x.a[4].set(true);
			x.a[5].set(false);
			x.a[6].set(true);
			x.a[7].set(true);
			x.a[8].set(false);
			x.a[9].set(true);
			x.a[10].set(true);
			
			x.b[0].set(true);
			x.b[1].set(true);
			x.b[2].set(true);
			x.b[3].set(true);
			x.b[4].set(false);
			x.b[5].set(true);
			x.b[6].set(false);
			x.b[7].set(true);
			x.b[8].set(true);
			x.b[9].set(true);
			x.b[10].set(false);
			
			x.aluOp[0].set(false);
			x.aluOp[1].set(false);
			x.aluOp[2].set(true);
			
			x.execute();
				
			
			String bString = "True";
			System.out.print("===================================================\n");
			System.out.print("|              ALU TEST_XOR_Negation              |\n");
			System.out.print("===================================================\n\n");
			
			System.out.printf("WELCOME! We'll going through XOR with Negation Today!\n");
			System.out.printf("Leftmost bit is the most significant!\n");
			
			System.out.printf("\nWill b be inverted? %s\n", bString);
			System.out.print("Numbers of Bits (X): 11\n");
			System.out.print("===================================================\n");
			System.out.print("|                     Inputs                      |\n");
			System.out.print("===================================================\n");
			
			System.out.print("a: ");
			print_binary(x.a);
			System.out.print("");
			System.out.print("b: ");
			print_binary(x.b);
			System.out.print("");
			System.out.print("aluOp: ");
			print_binary(x.aluOp);
			System.out.print("");
			System.out.print("===================================================\n");
			System.out.print("|                     NEGATION                    |\n");
			System.out.print("===================================================\n");
			System.out.print("a: ");
			print_binary(x.a);
			System.out.print("");
			System.out.print("b: 10001010000\n");
			System.out.print("===================================================\n");
			System.out.print("|                     Output                      |\n");
			System.out.print("===================================================\n");
			
			RussWire[] expected = new RussWire[11];
			
			for(int i = 0; i < 11; i++) {
				expected[i] = new RussWire(); 
			}
			
			expected[0].set(false);
			expected[1].set(false);
			expected[2].set(false);
			expected[3].set(true);
			expected[4].set(false);
			expected[5].set(false);
			expected[6].set(false);
			expected[7].set(true);
			expected[8].set(false);
			expected[9].set(true);
			expected[10].set(false);
	
			
			System.out.print("Your Result    : ");
			print_binary(x.result);
			System.out.print("");
			System.out.print("Expected Result: ");
			print_binary(expected);
			System.out.print("");
			
			System.out.printf("\nThank you for coming and good luck on your work! :)\n");
			
		}
	
		public static void print_binary(RussWire[] bits)
		{
			for (int i= bits.length-1; i>=0; i--)
			{
				System.out.printf("%d", (bits[i].get()?1:0));
			}
			System.out.printf("\n");
		}
}
