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

#### Input
Every log is considered as an event. Event has to be ingested. This ingestion can be done by different mechanisms at the same time. One simple mechanism is JSON over HTTP/S. Think of them as listeners.

### Process
Think of this as a Ruby pure function which takes in an event in a format passed by Input stage, and returns an message of a specific format and which store to use to Output stage.

### Output
It takes a processed event and stores in a store. A store can be of a predefined type like a file or a database.


## Roadmap      
### 0.0.1
- [x] A basic HTTP listener for JSON events
- [x] A basic processor which converts JSON to a JSON string
- [x] A basic file writer which appends string into a file.

### 0.0.2     
- [x] Design a basic config format for above three stages
- [x] write a parser to parse that config file as an argument
- [ ] Refactor the code so that this configuration can be used

### 0.0.3        
- [ ] Design test cases
- [ ] Add test cases

### 0.0.4      
- [ ] Add support for message buffering.
- [ ] Add support for output file rotation strategy. 


### 0.0.5     
- [ ] Document code so far
- [ ] Add support for regex filter and mutation. 
