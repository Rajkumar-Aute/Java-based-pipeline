package in.devsecopsguru.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@SpringBootApplication
@Controller
public class DevSecOpsApplication {

    public static void main(String[] args) {
        SpringApplication.run(DevSecOpsApplication.class, args);
    }

    // This method handles traffic to the root URL "/"
    @GetMapping("/")
    public String index(Model model) {
        // 1. Get Date and Time
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        model.addAttribute("dateTime", now.format(formatter));

        // 2. Get Hostname (Great for verifying which Kubernetes Pod you are hitting)
        String hostname;
        try {
            hostname = InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            hostname = "Unknown Host";
        }
        model.addAttribute("hostname", hostname);

        // 3. Return the name of the HTML template to render
        return "index";
    }
}