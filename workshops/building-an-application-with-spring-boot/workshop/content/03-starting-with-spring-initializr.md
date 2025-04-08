+++
Title = 'Starting with Spring Initializr'
+++

To manually initialize the project:

1.  Select the **Spring Initializr** tab to the right. This service
    pulls in all the dependencies you need for an application and does
    most of the setup for you.

    > If you want to create your own Spring Boot-based project while not following the guide, you would visit [Spring Initializr](https://start.spring.io/), fill in your project details, pick your options, and download a bundled up project as a zip file. For this guide, though, we have supplied the Spring Initializr interface in a tab to the right.

    In order to setup for this guide,
    configure your application as follows:

2.  Choose `Gradle-Groovy` as your **Project** type.

3.  Choose `Java` as the **Language** you want to use.

4.  In the **Project Metadata** section, set the value of the
    **Artifact** field to `springboot`.

5.  Click **Add Dependencies** in the upper right (or **Add** in the
    lower right) for smaller screen resolution) and select `Spring Web`.

6.  Click the **Create** button.

You will see that the resulting project is downloaded as a ZIP file:
`springboot.zip`, and then unzipped in the **Terminal** tab, to the
right, into the `springboot` directory. This directory contains a
ready-to-run Spring Boot application. For the rest of the guide, you’ll
be editing the application. Go ahead and explore it using the **Editor**
tab to the right.
