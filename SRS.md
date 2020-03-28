# Software Requirements Specification
## For <project name>

Version 0.1  
Prepared by <author>  
<organization>  
<date created>  

Table of Contents
=================
* [Revision History](#revision-history)
* 1 [Introduction](#1-introduction)
  * 1.1 [Document Purpose](#11-document-purpose)
  * 1.2 [Product Scope](#12-product-scope)
  * 1.3 [Definitions, Acronyms and Abbreviations](#13-definitions-acronyms-and-abbreviations)
  * 1.4 [References](#14-references)
  * 1.5 [Document Overview](#15-document-overview)
* 2 [Product Overview](#2-product-overview)
  * 2.1 [Product Perspective](#21-product-perspective)
  * 2.2 [Product Functions](#22-product-functions)
  * 2.3 [Product Constraints](#23-product-constraints)
  * 2.4 [User Characteristics](#24-user-characteristics)
  * 2.5 [Assumptions and Dependencies](#25-assumptions-and-dependencies)
* 3 [Requirements](#3-requirements)
  * 3.1 [External Interfaces](#31-external-interfaces)
    * 3.1.1 [User Interfaces](#311-user-interfaces)
    * 3.1.2 [Hardware Interfaces](#312-hardware-interfaces)
    * 3.1.3 [Software Interfaces](#313-software-interfaces)
    * 3.1.4 [Comunication](#314-comunication)
  * 3.2 [Functional](#32-functional)
  	* 3.2.1 [User class 1](#321-user-class-1)
  	* 3.2.2	[User class 2](#322-user-class-2)
  * 3.3 [Desing Requirements](#33-design-requirements)
    * 3.3.1 [Performance](#331-performance)
  * 3.4 [Design Constraints](#34-design-constraints)
  * 3.5 [Atributes](#35-design-and-implementation)
* 4 [Appendixes](#5-appendixes)

## Revision History
| Name | Date    | Reason For Changes  | Version   |
| ---- | ------- | ------------------- | --------- |
|      |         |                     |           |
|      |         |                     |           |
|      |         |                     |           |


## 1. Introduction
This section gives a description and a overview of everything included in this SRS document. Also, the purpose for this document is described and a list of abbreviations and definitions is provided.

### 1.1 Document Purpose
The purpose of this document is to give a detailed description of the requirements for the "D.A.N.S" (Document administration & notification system) software. It will illustrate the purpose and complete declaration for the development of system. It will also explain system constraints, interface and interactions with the users. This document is primarily intended to be proposed to a professor for its approval and a reference for developing the system for the development team.


### 1.2 Product Scope
<t traducir >

Este sotfware se basa en realizar un sistema que notifique a sus usuarios cuando un "admin" suba un documento. Este estara implementado en una aplicacion web.
El sistema emitira una notificacion cuando alguien suba un acta de elevada importancia o sea de interes para ciertos usuarios, los cuales estaran suscritos a dicho tema de interes. 
El uso de este software es totalmente libre y gratuito.

### 1.3 Definitions, Acronyms and Abbreviations
<t traducir>

|   Term        |                      Definitions                                           | 
| :-----------: | :------------------------------------------------------------------------: | 
| Admin         | Personas que suben documentos y tagean a los involucrados                  |                                
| Documents     | Actas de la U.N.R.C (Universidad Nacional de Rio Cuarto)subidas al sistema |                                 
| Users         | Personas que entran al sistema                                             |  
| Invited Users | Usuarios que ingresan sin registro previo                                  |                             


### 1.4 References 

* The srs example from https://github.com/jam01/SRS-Template.
* Arsaute A., Brusatti F., Solivellas D., Uva M., "srs". Unpublished slideshow.


### 1.5 Document Overview

The remainder of this document includes two more chapters and an appendixes. The second one provides an overview of the system functionality and system interaction with other systems. This chapter also introduces different types of stakeholders and their interaction with the system. Further, the chapter also mentions the system constraints andassumptions about the product.The third chapter provides the requirements specification in detailed terms and a description ofthe different system interfaces.

## 2. Product Overview

### 2.1 Product Perspective
<t traducir>

Este software es un producto nuevo y autocontenido que nace de la necesidad de tener un sistema eficiente para la correcta informacion y notificacion de nuevas actas. Este sistema constara de un portal web donde se administrarán Documentos y usuarios (users and admins) guardados en una base de datos. Los documentos seran subidos y al mismo tiempo, tanto los involucrados como los suscritos al tema de interés, seran notificados. 

### 2.2 Product Functions
<cambiar, traducir>

-listado funciones principales del software-

Con el portal web los admins podran administrar los documentos, ya sea subirlos, editaros, clasificarlos o eliminaros, mientras que los usuarios podran ver y buscar estos, suscribirse a temas de interes, y ademas seran notificados cuando corresponda. Tambien existira la posibilidad de ingresar como invitado, el cual solo podra ver y/o buscar las actas.



### 2.3 Product Constraints
<t traducir>
Esta seccion provee una vision de las restricciones o limitaciones de nuestro software, las cuales son:  

* Las actas solo estaran ordenadas por orden cronologico.
* Solo se podran etiquetar personas que contengan cuenta.
* Las actas solo podran ser buscadas por fecha, categoria y/o etiquetados.
* Los documentos a subir deben cumplir restricciones de formato.


### 2.4 User Characteristics

In this system there will be three types of users that interact with it:

| Name          | Permission    |                   What they can do                             | 
| :-----------: | :-----------: | :------------------------------------------------------------: |                    
| Invited User  |   None        | See and browse for documents                                   | 
| User          |   None        | Invited User + subscribe to topics of interest and be notified |  
| Admin         |   All         | User + load, edit, classify and eliminate documents            |          


### 2.5 Assumptions and Dependencies
<incompleto, traducir>

* El software funcionara para cualquier navegador
* El usuario deberá tener conexion a internet



## 3. Requirements
<incompleto>
> This section specifies the software product's requirements. Specify all of the software requirements to a level of detail sufficient to enable designers to design a software system to satisfy those requirements, and to enable testers to test that the software system satisfies those requirements.

> The specific requirements should:
* Be uniquely identifiable.
* State the subject of the requirement (e.g., system, software, etc.) and what shall be done.
* Optionally state the conditions and constraints, if any.
* Describe every input (stimulus) into the software system, every output (response) from the software system, and all functions performed by the software system in response to an input or in support of an output.
* Be verifiable (e.g., the requirement realization can be proven to the customer's satisfaction)
* Conform to agreed upon syntax, keywords, and terms.

### 3.1 External Interfaces
<incompleto>
> This subsection defines all the inputs into and outputs requirements of the software system. Each interface defined may include the following content:
* Name of item
* Source of input or destination of output
* Valid range, accuracy, and/or tolerance
* Units of measure
* Timing
* Relationships to other inputs/outputs
* Screen formats/organization
* Window formats/organization
* Data formats
* Command formats
* End messages

#### 3.1.1 User interfaces
<incompleto>
Define the software components for which a user interface is needed. Describe the logical characteristics of each interface between the software product and the users. This may include sample screen images, any GUI standards or product family style guides that are to be followed, screen layout constraints, standard buttons and functions (e.g., help) that will appear on every screen, keyboard shortcuts, error message display standards, and so on. Details of the user interface design should be documented in a separate user interface specification.

Could be further divided into Usability and Convenience requirements.

#### 3.1.2 Hardware interfaces
<incompleto>
Describe the logical and physical characteristics of each interface between the software product and the hardware components of the system. This may include the supported device types, the nature of the data and control interactions between the software and the hardware, and communication protocols to be used.

#### 3.1.3 Software interfaces
<incompleto>
Describe the connections between this product and other specific software components (name and version), including databases, operating systems, tools, libraries, and integrated commercial components. Identify the data items or messages coming into the system and going out and describe the purpose of each. Describe the services needed and the nature of communications. Refer to documents that describe detailed application programming interface protocols. Identify data that will be shared across software components. If the data sharing mechanism must be implemented in a specific way (for example, use of a global data area in a multitasking operating system), specify this as an implementation constraint.

#### 3.1.4 Comunication
<incompleto>

### 3.2 Functional
<incompleto>
> This section specifies the requirements of functional effects that the software-to-be is to have on its environment.

#### 3.2.1 User Class 1
<incompleto>
fotito UML ///Diagrama de clases////

#### 3.2.2 User Class 2
<incompleto>
Historias (Issues)


#### 3.3 Desing Requirements
<incompleto>
> This section states additional, quality-related property requirements that the functional effects of the software should present.

#### 3.3.1 Performance
<incompleto>
If there are performance requirements for the product under various circumstances, state them here and explain their rationale, to help the developers understand the intent and make suitable design choices. Specify the timing relationships for real time systems. Make such requirements as specific as possible. You may need to state performance requirements for individual functional requirements or features.

### 3.4 Design Constraints
<incompleto>
Specify the requirements derived from existing standards or regulations, including:  
* Report format
* Data naming
* Accounting procedures
* Audit tracing

For example, this could specify the requirement for software to trace processing activity. Such traces are needed for some applications to meet minimum regulatory or financial standards. An audit trace requirement may, for example, state that all changes to a payroll database shall be recorded in a trace file with before and after values.

### 3.5 Atributes