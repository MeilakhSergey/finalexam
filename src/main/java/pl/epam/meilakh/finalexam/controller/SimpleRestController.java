package pl.epam.meilakh.finalexam.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SimpleRestController {

    @GetMapping("/hello")
    public String getHello() {
        return "Hello";
    }

    @GetMapping("/")
    public String works() {
        return "It's ALIVE!!!!!!     ALIVE!!!!!";
    }
}
