package com.example.n8n_cicd;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping()
public class HealthCheckController {

    @RequestMapping("/health")
    public String healthCheck() {
        return "Hello World!";
    }

}
