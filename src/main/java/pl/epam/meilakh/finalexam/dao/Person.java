package pl.epam.meilakh.finalexam.dao;

import lombok.Getter;
import lombok.Setter;

//import javax.persistence.Entity;
//import javax.persistence.GeneratedValue;
//import javax.persistence.GenerationType;
//import javax.persistence.Id;

//@Entity
//@Getter @Setter
public class Person {

//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private Integer age;

    public String toString() {
        return "[Person: name: " + name + ", age: " + age;
    }
}
