package cz.cuni.mff.java.kubinja.reflection;

import java.lang.reflect.Modifier;
import java.lang.reflect.TypeVariable;
import java.util.Arrays;
import java.util.Scanner;

public class Main {
    static void printInfo(String className){
        Class<?> cls = Class.forName(className);

        System.out.println(cls.getName());

        if (cls.isPrimitive()) System.out.println("primitive");
        else if (cls.isArray()) System.out.println("array");
        else if (cls.isAnnotation()) System.out.println("annotation");
        else if (cls.isInterface()) System.out.println("interface");
        else if (cls.isEnum()) System.out.println("enum");
        else if (cls.isRecord()) System.out.println("record");
        else System.out.println("class");

        TypeVariable<? extends Class<?>>[] genericVariables = cls.getTypeParameters();
        System.out.print("Generic: " + (genericVariables.length != 0 ? "yes" : "no"));

        if (genericVariables.length > 0) {
            System.out.print(", Variables:");
            Arrays.stream(genericVariables).forEach(m -> System.out.print(" " + m.getName()));
        }

        System.out.println();

        System.out.println(cls.getSuperclass() != null ? cls.getSuperclass().getName() : null);
        System.out.println(cls.getInterfaces().length);
        Arrays.stream(cls.getInterfaces()).map(Class::getName).forEach(System.out::println);

        System.out.println(cls.getMethods().length);
        System.out.println(Arrays.stream(cls.getMethods()).filter(m -> Modifier.isStatic(m.getModifiers())).count());
        System.out.println(cls.getClasses().length);
        Arrays.stream(cls.getClasses()).map(Class::getName).forEach(System.out::println);
    }

    static void main() {
        Scanner scanner = new Scanner(System.in)
        String className;
        while (scanner.hasNext()) {
            className = scanner.nextLine();

            printInfo(className);

            System.out.println();
        }
    }
}