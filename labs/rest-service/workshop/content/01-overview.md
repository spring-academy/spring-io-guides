+++
Title = 'Building a RESTful Web Service'
+++

This guide walks you through the process of creating a "`Hello, World`" RESTful web
service with Spring.

## What You Will Build

You will build a service that will accept HTTP GET requests at
[`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting`](`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting`).

It will respond with a JSON representation of a greeting, as the following listing shows:

```json
{ "id": 1, "content": "Hello, World!" }
```

You can customize the greeting with an optional `name` parameter in the query string, as
the following listing shows:

[`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting?name=User`](`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting?name=User`)

The `name` parameter value overrides the default value of `World` and is reflected in the
response, as the following listing shows:

```json
{ "id": 1, "content": "Hello, User!" }
```

## Create a Resource Representation Class

Now that you have set up the project and build system, you can create your web service.

Begin the process by thinking about service interactions.

The service will handle `GET` requests for `/greeting`, optionally with a `name` parameter
in the query string. The `GET` request should return a `200 OK` response with JSON in the
body that represents a greeting. It should resemble the following output:

```json
{
  "id": 1,
  "content": "Hello, World!"
}
```

The `id` field is a unique identifier for the greeting, and `content` is the textual
representation of the greeting.

To model the greeting representation, create a resource representation class. To do so,
provide a Java record class for the `id` and `content` data, as the following listing (from
`complete/src/main/java/com/example/restservice/Greeting.java`) shows:

```java
package com.example.restservice;

public record Greeting(long id, String content) { }
```

{{< note >}}
This application uses the https://github.com/FasterXML/jackson[Jackson JSON] library to
automatically marshal instances of type `Greeting` into JSON. Jackson is included by default by the web starter.
{{< /note >}}

## Create a Resource Controller

In Spring's approach to building RESTful web services, HTTP requests are handled by a
controller.
These components are identified by the
[`@RestController`](https://docs.spring.io/spring/docs/{spring_version}/javadoc-api/org/springframework/web/bind/annotation/RestController.html)
annotation,
and the `GreetingController` shown in the following listing
(from `complete/src/main/java/com/example/restservice/GreetingController.java`)
handles `GET` requests for `/greeting` by returning a new instance of the `Greeting` class:

```java
package com.example.restservice;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

	private static final String template = "Hello, %s!";
	private final AtomicLong counter = new AtomicLong();

	@GetMapping("/greeting")
	public Greeting greeting(@RequestParam(value = "name", defaultValue = "World") String name) {
		return new Greeting(counter.incrementAndGet(), String.format(template, name));
	}
}
```

This controller is concise and simple, but there is plenty going on under the hood. We
break it down step by step.

The `@GetMapping` annotation ensures that HTTP GET requests to `/greeting` are mapped to the `greeting()` method.

{{< note >}}
There are companion annotations for other HTTP verbs (e.g. `@PostMapping` for POST). There is also a `@RequestMapping` annotation that they all derive from, and can serve as a synonym (e.g. `@RequestMapping(method=GET)`).
{{< /note >}}

`@RequestParam` binds the value of the query string parameter `name` into the `name`
parameter of the `greeting()` method. If the `name` parameter is absent in the request,
the `defaultValue` of `World` is used.

The implementation of the method body creates and returns a new `Greeting` object with
`id` and `content` attributes based on the next value from the `counter` and formats the
given `name` by using the greeting `template`.

A key difference between a traditional MVC controller and the RESTful web service
controller shown earlier is the way that the HTTP response body is created. Rather than
relying on a view technology to perform server-side rendering of the greeting data to
HTML, this RESTful web service controller populates and returns a `Greeting` object. The
object data will be written directly to the HTTP response as JSON.

This code uses Spring
[`@RestController`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/bind/annotation/RestController.html)
annotation, which marks the class as a controller where every method returns a domain
object instead of a view. It is shorthand for including both `@Controller` and
`@ResponseBody`.

The `Greeting` object must be converted to JSON. Thanks to Spring's HTTP message converter
support, you need not do this conversion manually. Because
[Jackson 2](https://github.com/FasterXML/jackson) is on the classpath, Spring's
[`MappingJackson2HttpMessageConverter`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/http/converter/json/MappingJackson2HttpMessageConverter.html)
is automatically chosen to convert the `Greeting` instance to JSON.

`@SpringBootApplication` is a convenience annotation that adds all of the following:

- `@Configuration`: Tags the class as a source of bean definitions for the application
  context.
- `@EnableAutoConfiguration`: Tells Spring Boot to start adding beans based on classpath
  settings, other beans, and various property settings. For example, if `spring-webmvc` is
  on the classpath, this annotation flags the application as a web application and activates
  key behaviors, such as setting up a `DispatcherServlet`.
- `@ComponentScan`: Tells Spring to look for other components, configurations, and
  services in the `com/example` package, letting it find the controllers.

The `main()` method uses Spring Boot's `SpringApplication.run()` method to launch an
application. Did you notice that there was not a single line of XML? There is no `web.xml`
file, either. This web application is 100% pure Java and you did not have to deal with
configuring any plumbing or infrastructure.

### Run the Application

You can run the application from the command line using Gradle or Maven.

If you use Gradle, you can run the application by using `./gradlew bootRun`.

```bash
$ cd complete
$ ./gradlew bootRun
```

If you use Maven, you can run the application by using `./mvnw spring-boot:run`.

```bash
$ cd complete
$ ./mvnw spring-boot:run
```

Logging output is displayed. The service should be up and running within a few seconds.

## Test the Service

Now that the service is up,
visit [`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting`](`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting`),
where you should see:

```json
{ "id": 1, "content": "Hello, World!" }
```

Provide a `name` query string parameter by visiting
[`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting?name=User`](`{{% param ingress_protocol %}}://editor-{{% param session_namespace %}}.{{% param ingress_domain %}}/proxy/8080/greeting?name=User`).
Notice how the value of the `content` attribute changes from `Hello, World!` to `Hello, User!`, as the following listing shows:

```json
{ "id": 2, "content": "Hello, User!" }
```

This change demonstrates that the `@RequestParam` arrangement in `GreetingController` is
working as expected. The `name` parameter has been given a default value of `World` but
can be explicitly overridden through the query string.

Notice also how the `id` attribute has changed from `1` to `2`. This proves that you are
working against the same `GreetingController` instance across multiple requests and that
its `counter` field is being incremented on each call as expected.

## Summary

Congratulations! You have just developed a RESTful web service with Spring.

## See Also

The following guides may also be helpful:

- [Accessing GemFire Data with REST](https://spring.io/guides/gs/accessing-gemfire-data-rest/)
- [Accessing MongoDB Data with REST](https://spring.io/guides/gs/accessing-mongodb-data-rest/)
- [Accessing data with MySQL](https://spring.io/guides/gs/accessing-data-mysql/)
- [Accessing JPA Data with REST](https://spring.io/guides/gs/accessing-data-rest/)
- [Accessing Neo4j Data with REST](https://spring.io/guides/gs/accessing-neo4j-data-rest/)
- [Consuming a RESTful Web Service](https://spring.io/guides/gs/consuming-rest/)
- [Consuming a RESTful Web Service with AngularJS](https://spring.io/guides/gs/consuming-rest-angularjs/)
- [Consuming a RESTful Web Service with jQuery](https://spring.io/guides/gs/consuming-rest-jquery/)
- [Consuming a RESTful Web Service with RestTemplate](https://spring.io/guides/gs/consuming-rest/)
- [Securing a Web Application](https://spring.io/guides/gs/securing-web/)
- [Building REST services with Spring](https://spring.io/guides/tutorials/rest/)
- [React.js and Spring Data REST](https://spring.io/guides/tutorials/react-and-spring-data-rest/)
- [Building an Application with Spring Boot](https://spring.io/guides/gs/spring-boot/)
- [Creating API Documentation with Restdocs](https://spring.io/guides/gs/testing-restdocs/)
- [Enabling Cross Origin Requests for a RESTful Web Service](https://spring.io/guides/gs/rest-service-cors/)
- [Building a Hypermedia-Driven RESTful Web Service](https://spring.io/guides/gs/rest-hateoas/)
- [Circuit Breaker](https://spring.io/guides/gs/circuit-breaker/)

Want to write a new guide or contribute to an existing one?
Check out our [contribution guidelines](https://github.com/spring-guides/getting-started-guides/wiki).

{{< warning >}}
All guides are released with an ASLv2 license for the code,
and an [Attribution, NoDerivatives creative commons license](http://creativecommons.org/licenses/by-nd/3.0/) for the writing.
{{< /warning >}}
