class A {
    private final String name = "A";

    public A(String name){
        this.name = name;

        System.out.println("A");

        List<String> list = new ArrayList<>();
        list.add("Hello");
        list.add("World");

        for (String i : list) {
            System.out.println(i);
        }

        while (false) {System.out.println("This will never be printed");}
    }

    private String getName(){
        return name;
    }
}