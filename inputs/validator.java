package cz.cuni.mff.java.hw.validation;

import cz.cuni.mff.java.hw.validation.annotations.*;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.Map;
import java.util.stream.Stream;

public class Validator {
    private static Stream<Field> getFields(Class<?> clazz) {
        if (clazz == null){
            return Stream.empty();
        }

        return Stream.concat(
                Arrays.stream(clazz.getDeclaredFields()),
                getFields(clazz.getSuperclass())
        );
    }

    public static boolean isValid(Object o) {
        try {
            for (Field field : getFields(o.getClass()).toArray(Field[]::new)) {
                field.setAccessible(true);

                if (Arrays.stream(field.getAnnotations()).anyMatch(a -> a.annotationType().equals(Ignored.class))){
                    continue;
                }

                for (Annotation annotation : field.getAnnotations()){
                    if (annotation.annotationType().equals(AssertFalse.class)){
                        if (!(field.getType().equals(boolean.class) || field.getType().equals(Boolean.class))){
                            return false;
                        }

                        if (field.getType().equals(boolean.class) && field.getBoolean(o)){
                            return false;
                        } else if (field.getType().equals(Boolean.class)){
                            Boolean b = (Boolean) field.get(o);

                            if (b == null || b){
                                return false;
                            }
                        }
                    } else if (annotation.annotationType().equals(AssertTrue.class)){
                        if (!(field.getType().equals(boolean.class) || field.getType().equals(Boolean.class))){
                            return false;
                        }

                        if (field.getType().equals(boolean.class) && !field.getBoolean(o)){
                            return false;
                        } else if (field.getType().equals(Boolean.class)){
                            Boolean b = (Boolean) field.get(o);

                            if (b == null || !b){
                                return false;
                            }
                        }
                    } else if (annotation.annotationType().equals(Future.class)){
                        if (!field.getType().equals(LocalDateTime.class)){
                            return false;
                        }

                        LocalDateTime t = (LocalDateTime) field.get(o);

                        if (t == null || LocalDateTime.now().isAfter(t)){
                            return false;
                        }
                    } else if (annotation.annotationType().equals(NotBlank.class)){
                        if (!field.getType().equals(String.class)){
                            return false;
                        }

                        String s = (String) field.get(o);

                        if (s == null || s.isBlank()){
                            return false;
                        }
                    } else if (annotation.annotationType().equals(NotNull.class)){
                        Object obj = field.get(o);

                        if (obj == null){
                            return false;
                        }
                    } else if (annotation.annotationType().equals(Null.class)){
                        Object obj = field.get(o);

                        if (obj != null){
                            return false;
                        }
                    } else if (annotation.annotationType().equals(Pattern.class)){
                        if (!field.getType().equals(String.class)){
                            return false;
                        }

                        String s = (String) field.get(o);
                        String regex = ((Pattern) annotation).regexp();

                        if (s == null || regex == null){
                            return false;
                        }

                        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(regex);
                        if (!pattern.matcher(s).matches()){
                            return false;
                        }
                    } else if (annotation.annotationType().equals(Size.class)){
                        Size annot = (Size) annotation;

                        int size = annot.size();

                        if (field.getType().equals(String.class)){
                            String s = (String) field.get(o);

                            if (s == null || s.length() != size){
                                return false;
                            }
                        } else if (field.get(o) instanceof Collection<?> collection) {
                            if (collection.size() != size){
                                return false;
                            }
                        } else if (field.get(o) instanceof Map<?, ?> map) {
                            if (map.size() != size){
                                return false;
                            }
                        } else if (annotation.annotationType().isArray()){
                            Object[] array = (Object[]) field.get(o);

                            if (array == null || array.length != size){
                                return false;
                            }
                        }
                    }
                }
            }
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }


        return true;
    }

    public static void validate(Object o) throws ValidationException {
        if (!isValid(o)) {
            throw new ValidationException();
        }
    }

}