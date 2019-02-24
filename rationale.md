# Rationale 

An explanation of how I thought of solving the challenge.

For the references of the documentation used, check the
[References](./references.md) page



# Components Diagram and Breakdown


This little diagram explains the components/resources used in this setup


        +-------------------+
        |                   |
        |       C D N       |
        |                   |
        +---------+---------+
                  |
                  v
        +---------+---------+   +-----------------+
        |                   |   |                 |
        |  nginx-ingress    +-->+  metrics-to-sd  |
        |                   |   |                 |
        +---------+---------+   +-----------------+
                  |
                  v
        +---------+---------+
        |                   |
        |  website (nginx)  |
        |                   |
        +---------+---------+
                  |
                  v
        +---------+---------+
        |                   |
        |  Database (MySQL) |
        |                   |
        +-------------------+
        


## CDN

I don't know much about Google CDN, so I had to spend quite a bit of time 
investigating how it is supposed to work.

As far as I could see, we will need to handle HTTP headers in the app/website
itself, and ensure the cache is up to date.

## Ingress and load balancing

I took a look at the most common load balancing solutions, and the nginx-ingress
seems to be the most accepted one. 

## Monitoring and Metrics using StackDriver

To push the metrics, I have chosen running a sidecar container capable of looking
at the nginx statistics, crunch them, and send them to SD where alerts and
actionables can be created. 

I wanted to use [**StackDriver Kubernetes Monitoring**](https://cloud.google.com/monitoring/kubernetes-engine/) 
currently in Beta, instead of the legacy stackdriver. 

## Website

To keep the website itself testable and "movable", I decided to keep it inside
it's own container, instead of mixing concerns with the ingress.
This way we can benefit from better compoundability and less worries during
development and testing, with little overhead.

This container also hase a Permanent Volume so it can store assets (images, etc).

There are a couple things that this "service" or "website" will have to care for:

- Ensure the caching headers are handled correctly. Letting google's CD N know 
  what needs to be refreshed and what doesn't.

- Ensure we are showing the right version and language of the website, based on
  the host header of the request.


## Database

In this case, I used a container (with permanent volumes) running on top of k8s,
instead of the Google provided database instances, just to keep the "challenge" 
brief. 
In a production/product environment, I would probably lean more in favour of a 
more reliable managed solution like GoogleSQL, which provides more advance data
management capabilities.


# Current Status

The challenge was not fully solved/completed, so here it is a quick summary
of the activities that were completed and which ones are still open.

### Done

+ Kubernetes defition of services, and deployable in GKE
+ Deploying nginx-ingress and pushing metrics to stackdriver

### Pending

- Missing the right metrics to measure the traffic sent to a give pod
- missing the CDN link
- In a production setup, it seems to be a better idea to use something 
  more robust for the database than just simple pod with p.v.



