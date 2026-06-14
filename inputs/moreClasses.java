package org.example;

class A {
    private static int i;
    public static void main(String[] args) {
        String message = "Hello, World!";
        for (
            i = 0; 
i < 5; 
                        i++) {System.out.println(message + " " + i);}
    }
}

class B {
    public B() {System.out.println("Hello from class B!");}

    public int fibonacci(int n) {
        if (n <= 1) {return n;}
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}