package ar.com.macro.apirest.base;

import com.atlassian.oai.validator.OpenApiInteractionValidator;
import com.atlassian.oai.validator.report.LevelResolver;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import static com.atlassian.oai.validator.report.ValidationReport.Level.IGNORE;

@SpringBootApplication
@EnableScheduling
@ComponentScan(basePackages = {"ar.com.macro"})
public class Application {

    @Value("${app.oas}")
    private String oas;

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public OpenApiInteractionValidator validator() {
        final OpenApiInteractionValidator validator = OpenApiInteractionValidator
                .createFor(oas)
                .withLevelResolver(
                        // The key here is to use the level resolver to ignore the response validation messages
                        // Without this they would be emitted at ERROR level and cause a validation failure.
                        LevelResolver.create()
                                .withLevel("validation.response", IGNORE)
                                .build()
                )
                .build();

        return validator;
    }
}