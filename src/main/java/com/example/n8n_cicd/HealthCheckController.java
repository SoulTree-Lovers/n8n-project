package com.example.n8n_cicd;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping()
public class HealthCheckController {

    @RequestMapping("/health")
    public String healthCheck() {
        return "서버가 정상 작동합니다!\n This is a health check endpoint.\n  The application is running.";
    }

}
