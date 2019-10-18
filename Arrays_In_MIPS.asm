.data 

array: .space 40 
createArray: .asciiz "Please enter 10 integer values: "
menuPrompt: .asciiz  "\n\nMenu (enter an int as your choice):\n1)Replace an element at a certain position\n2)Remove the max element\n3)Remove the min element \n4)Compute values and exit \nWhat would you like to do? "
printArr: .asciiz   "\nYour values are: " 
printRE: .asciiz "What position from the array do you wish to replace? " 
printRE2: .asciiz "What value do you want to change it to? "
compVal: .asciiz "The summation of all values in the array is: "
compVal_2: .asciiz ", the product of all values in the array is: " 
space: .asciiz " "
			
.text			
.globl main 

main: 
   #Hold array size so that 
   #we can decrement the size for removeMax/removeMin 
   ori $t7, $0, 40 
   
   
   #Prompt the user to enter 10 values 
   li $v0, 4 
   la $a0, createArray 
   syscall  
   
   
   #Use loop to collect all values in array 
   ori $t0, $0, 0
 loopCollectArrayValues:
   bge $t0, $t7, prePrintCondition
   li $v0, 5
   syscall
   
   sw $v0, array($t0) 
   addiu $t0, $t0, 4
   j loopCollectArrayValues    
   
   
   #Use this symbolic address to clear $t0 
   #and to print the printArr string 
 prePrintCondition: 
   ori $t0, $0, 0 
   li $v0, 4 
   la $a0, printArr
   syscall
   
   j printArray 
   
   #Prints integer and a space until $t0 >= $t7 
 printArray:
   bge $t0, $t7, menu
   li $v0, 1 
   lw $a0, array($t0) 
   syscall
   
   li $v0, 4
   la $a0, space
   syscall
   
   addiu $t0, $t0, 4
   j printArray   
   
   
   #Prints menuPrompt and contains appropriates branches based on user input 
 menu: 
  li $v0, 4 
  la $a0, menuPrompt 
  syscall
  
  li $v0, 5
  syscall
  
  beq $v0, 1, replaceElement 
  beq $v0, 2, removeMax 
  beq $v0, 3, removeMin
  beq $v0, 4, computeVal

  
  #Takes index, multiplies by four, and takes new value 
  #and stores value in array(index)   
 replaceElement: 
  li $v0, 4
  la $a0, printRE
  syscall 
  
  li $v0, 5
  syscall 
  
  addiu $v0, $v0, -1 
  sll $v0, $v0, 2
  move $t0, $v0 
  
  li $v0, 4 
  la $a0, printRE2
  syscall 
  
  li $v0, 5
  syscall 
  
  sw $v0, array($t0)
  j prePrintCondition

  
  #$t0 contains index of current maximum and is updated
  #every time there is a succeeding value that is greater
  #Decrements size of array and restores all values except max value
 removeMax:   
  ori $t0, $0, 0 
  ori $t1, $0, 0
 
  outerLoop: 
  addiu $t1, $t1, 4
  bge $t1, $t7, prepFill 
  
  lw $t2, array($t0) 
  lw $t3, array($t1) 
  
  bgt $t2, $t3, outerLoop
  or $t0, $0, $t1 
  j outerLoop

  prepFill:
  addiu $t7, $t7, -4 
  ori $t1, $0, 0 
  ori $t2, $0, 0 
  j refillArray 

  refillArray:
  bge $t2, $t7, prePrintCondition 
  bne $t1, $t0, copy
  addiu $t1, $t1, 4  
  
  copy: 
  lw $t3, array($t1)
  sw $t3, array($t2)
  
  addiu $t1, $t1, 4 
  addiu $t2, $t2, 4
  j refillArray	

  
  #$t0 contains index of current minimum and is updated
  #every time there is a succeeding value that is lesser
  #Decrements size of array and restores all values except min value   
 removeMin: 
  ori $t0, $0, 0 
  ori $t1, $0, 0
 
  outerLoopMin: 
  addiu $t1, $t1, 4
  bge $t1, $t7, prepFillMin 
  
  lw $t2, array($t0) 
  lw $t3, array($t1) 
  
  blt $t2, $t3, outerLoopMin
  or $t0, $0, $t1 
  j outerLoopMin

  prepFillMin:
  addiu $t7, $t7, -4 
  ori $t1, $0, 0 
  ori $t2, $0, 0 
  j refillMin 

  refillMin:
  bge $t2, $t7, prePrintCondition
  bne $t1, $t0, copyMin
  addiu $t1, $t1, 4  
  
  copyMin: 
  lw $t3, array($t1)
  sw $t3, array($t2)
  
  addiu $t1, $t1, 4 
  addiu $t2, $t2, 4
  j refillMin	

  
  #$t0 holds index, $t1 holds sum, and $t2 holds product 
 computeVal:
  ori $t0, $0, 0
  ori $t1, $0, 0 
  ori $t2, $0, 1 
  
  whileComputingVal: 
  bge $t0, $t7, print
  lw $t3, array($t0)
  
  addu $t1, $t1, $t3 
  mult $t2, $t3 
  mflo $t2 
  
  addiu $t0, $t0, 4
  j whileComputingVal 

  print: 
  li $v0, 4
  la $a0, compVal
  syscall 

  li $v0, 1 
  move $a0, $t1 
  syscall 

  li $v0, 4
  la $a0, compVal_2
  syscall 
  
  li $v0, 1
  move $a0, $t2
  syscall 
  
  j end
   
end: 
  li $v0, 10 
  syscall