package pl.epam.meilakh.finalexam.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import pl.epam.meilakh.finalexam.dao.Person;
import pl.epam.meilakh.finalexam.dao.PersonRepository;

import java.util.stream.Collectors;

@RestController
public class SimpleRestController {

    @Autowired
    private PersonRepository personRepository;

    @GetMapping("/hello")
    public String getHello() {
        return "Hello";
    }

    @GetMapping("/")
    public String works() {
        return "It's ALIVE!!!!!!     ALIVE!!!!!";
    }

    @GetMapping("/persons")
    public String getAll() {
        return personRepository.findAll().stream()
                .map(Person::toString)
                .collect(Collectors.joining());
    }

    @GetMapping("/persons/{id}")
    public Person getOne(@PathVariable Long id) {
        return personRepository.findById(id).orElseThrow();
    }
}
