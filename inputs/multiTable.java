package org.example;
public class Main {
    private static int number_size(int number){
        int size = 0;
        while (number > 0){size++;number /= 10;}
        return size;
    }
    public static void main(String[] args) {
        int max_multiplicand = 10;int number = Integer.parseInt(args[0]);
        int max_multiplication_size = number_size(number * max_multiplicand);int max_multiplicand_size = number_size(max_multiplicand);

        for (int multiplicand = 1; multiplicand <= max_multiplicand; multiplicand++){
            for (int multiplicand_size = number_size(multiplicand); multiplicand_size < max_multiplicand_size; multiplicand_size++){System.out.print(" ");}
            System.out.print(multiplicand + " * " + number + " = ");
            for (int multiplication_size = number_size(number * multiplicand); multiplication_size < max_multiplication_size; multiplication_size++){System.out.print(" ");}
            System.out.println(number * multiplicand);
        }
    }
}