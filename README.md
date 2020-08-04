# Logg

A simple **lo**g a**gg**regator service.       
*Not to be used in production yet.*

### Design
Logg keeps things simple and flexible. 

                    ____________        
                   |            |       
    EventA ------> |            | ---> Store1        
    EventB ------> |    Logg    |        
    EventC ------> |            | ---> Store2      
                   |____________|        


Logg itself comprises of three components.

     Input -> Process -> Output

These blocks can be configured by using a config file. The config file is just a declarative version of the system you want to run. You can declare multiple data stores, have each processor write to at least one store and define inputs and the way you want to process them.       
You can refer to the `config.yml` file in this same repo. Currently it defines a simple log file based store, which will be buffered and written to disk every 5 minutes. Then we have defined a processor, which takes an event, which is represented as a Ruby Hash, it does adds a pre processing block, which shows an exmpale how can we run custom mutation before and after our main default processing strategy. In the config it shows how to mask and IP address for hypothetical compliance reasons. We also define where does the output of this pipeline should be stored. We have specified the store we just defined previously. In the similar form, we define an Input which is of type http-json, which is a predefined input types, and the necessary options for it such as host and port. Then we also define which processor should be processing the events this input listens to. Once this file is ready, it can be consumed and validated by the `logg` and start the processing all the events. 

#### Input
Every log is considered as an event. Event has to be ingested. This ingestion can be done by different mechanisms at the same time. One simple mechanism is JSON over HTTP/S. Think of them as listeners.

### Process
Think of this as a Ruby pure function which takes in an event in a format passed by Input stage, and returns an message of a specific format and which store to use to Output stage.

### Output
It takes a processed event and stores in a store. A store can be of a predefined type like a file or a database or our just stdout them.

### Getting started       
1. Make sure you have `ruby` and `bundler` installed.
2. clone this repo
3. `cd logg`
4. `bundle install`
5. `bin/logg`

### Contributing
Things are still in progress. But I have basic tests ready, bunch of them are failing right now, you can test them by running `rspec`.

## Roadmap      
### 0.0.1
- [x] A basic HTTP listener for JSON events
- [x] A basic processor which converts JSON to a JSON string
- [x] A basic file writer which appends string into a file.

### 0.0.2     
- [x] Design a basic config format for above three stages
- [x] write a parser to parse that config file as an argument
- [x] Refactor the code so that this configuration can be used

### 0.0.3        
- [x] Design test cases
- [ ] Add test cases 
- [x] support for pre/post mutations

### 0.0.4      
- [ ] Add support for message buffering.
- [ ] Add support for output file rotation strategy. 


### 0.0.5     
- [x] Document code so far
- [ ] Add support for regex filter. 
