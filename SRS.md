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
This software is based in a notification system that emits an alert when an admin add a document. It will be implement using a web aplication.
The program emits a notification via e-mail when an admin uploead a document with lot of priorarity or when the user show some interest in a theme, previusly suscribed.
The software should be free to use for all the users.

### 1.3 Definitions, Acronyms and Abbreviations

|   Term        |                      Definitions                                           | 
| :-----------: | :------------------------------------------------------------------------: | 
| Admin         | People that upload the documents and add tags to them  |                                
| Documents| Proceedings from the N.U.R.C (Nacional University of Rio Cuarto)upload to the system |                                 
| Users         | People registed in the system                                             |  
| Invited Users | People that only can search and watch the documents       |                             


### 1.4 References 

* The srs example from https://github.com/jam01/SRS-Template.
* Arsaute A., Brusatti F., Solivellas D., Uva M., "srs". Unpublished slideshow.


### 1.5 Document Overview

The remainder of this document includes two more chapters and an appendixes. The second one provides an overview of the system functionality and system interaction with other systems. This chapter also introduces different types of stakeholders and their interaction with the system. Further, the chapter also mentions the system constraints andassumptions about the product.The third chapter provides the requirements specification in detailed terms and a description ofthe different system interfaces.

## 2. Product Overview

### 2.1 Product Perspective
This software is a new product and self-contained. It come aout from the necesity of have a efficent system for the notification of the documents. The system should have a web portal where the documents and users will be administered and save in a Data Base. The documents should be upload by the admins and the system will notificate immediately.

### 2.2 Product Functions

A list of the principal functions of the software is given:

- A Functtion that allow the admins users add, delete and edit documents
- The users should be able to search documents by the app Filter, looking for the date, the tags and the labelled users
- The users can add tags into theirs profile.
- The users should be notificated when a intrested document is added or when they are labelled in it.
- The invited user only can read and search documets

### 2.3 Product Constraints
This section provide a list of the restrictions or limitations of the software, which are:

* The documents are only sorted by the cronological order that are upload.
* The admins only can tag registed users.
* The documents only can be searched by date, tag or labelled.
* The documents only can be .PDF, the original format of the University web.


### 2.4 User Characteristics

In this system there will be three types of users that interact with it:

| Name          | Permission    |                   What they can do                             | 
| :-----------: | :-----------: | :------------------------------------------------------------: |                    
| Invited User  |   None        | See and browse for documents                                   | 
| User          |   None        | Invited User + subscribe to topics of interest and be notified |  
| Admin         |   All         | User + load, edit, classify and eliminate documents            |          


### 2.5 Assumptions and Dependencies

* The software will be designed for the most common web servidors, for example Google Chrome, Safari, Modzilla and Internet Explorer
* The user must have a conection to internet.



## 3. Requirements
This section specifies the software product's requirements.This section contains all of the functional and quality requirements of the system. It gives a detailed description of the system and all its features.


### 3.1 External Interfaces
This section provides a detailed description of all inputs into and outputs from the system. It also gives a description of the hardware, software and communication interfaces and provides basic prototypes of the user interface.

#### 3.1.1 User interfaces

A first-time user of the "D.A.N.S" should see the log-in page when he enter in the web page, see Figure 1. And register users have to log-in and identify itself. If the person don't want to get registered, he should be able to enter like a invited user. Every registed user should have a profile page where they can edit their e-mail address, username, password and apply for upgrade the acount, see Figure 2.A and Figure 2.N
Figure 1             |  Figure 2.A | Figure 2.N
:-------------------------:|:-------------------------:|:-------------------------:
![Imgur](https://i.imgur.com/yPFiAjj.png)|![Imgur](https://i.imgur.com/qfklgUp.png) | ![Imgur](https://i.imgur.com/dvGvwCc.png) 

Now, register users continue to the next interface, see Figure 3.A and Figure 3.N Here the user watch all the documents unread and he should be able to click in one of interest to expand it to watch it better. 
  Figure 3.A | Figure 3.N
:-------------------------:|:-------------------------:
![Imgur](https://i.imgur.com/la6UOSN.png) | ![Imgur](https://i.imgur.com/4fyaVWg.png) 

Another interface will be the page where the user can search and suscribe to some tags. See Figure 4.A and 4.N. A list of tags is shown and the user can select some of them. Each tag should give the number of documents that are vinculated to it.
  Figure 4.A | Figure 4.N 
:-------------------------:|:-------------------------: 
![Imgur](https://i.imgur.com/LxMVUhU.png)  | ![Imgur](https://i.imgur.com/WSj4KMj.png) |

In the search interface the user should be able to search documents by the date, a tag or the users labelled. See Figure 5.A, 5.N and 5.G.
  Figure 5.A | Figure 5.N | Figure 5.G
:-------------------------:|:-------------------------: |:-------------------------: 
![Imgur](https://i.imgur.com/AhBCmnK.png)   | ![Imgur](https://i.imgur.com/eeVlKWT.png)  | ![Imgur](https://i.imgur.com/hKsHoSD.png) 

All this interfaces are diferent for normal and admin users. The invited user only can use de all document page, se Figure 
Also we have the interface where the admin user should be able to add documents, vinculate de tags to it and label the users. See figure 6.
Figure 6 |
:-------------------------: |
![Imgur](https://i.imgur.com/v5Onuo0.png)  | 



#### 3.1.2 Hardware interfaces

Because the software is a web portal, only is needed the hardware required by by the Web navigator. The conecction with the Data Bases are administrated by the operating system. 


#### 3.1.3 Software interfaces

The web portal doesn't neeed another software, a conecction to the Data Base is only needed, when the users want to access to the information in it.

#### 3.1.4 Comunication

The comunication between the Data Base and the web portal consists in the search of documents, the tags (tags of documents and tags of users).


### 3.2 Functional

This section specifies the requirements of functional effects that the software should have on its environment.

#### 3.2.1 Class Diagram

UML Diagram |
:-------------------------: |
![Imgur](https://i.imgur.com/AY14C6M.png)  | 

#### 3.2.2 User Class - The User

##### 3.2.2.1 Functional 2.1

ID: FR1                                                               
TITLE: Enter the web.                                                   
DESC: A user should be able to access the web through any browser.                              
RAT: In order for a user to enter the web.                             
DEP: None                              

##### 3.2.2.1 Functional 2.2

ID: FR2                                                   
TITLE: User registration.                                           
DESC: Given that a user has into the web, then the user should be able to register through the beginin page. The user must provide his full name, id number, user-name, password and e-mail address.                                 
RAT: In order for a user to register on the web.                                                  
DEP: FR1

##### 3.2.2.1 Functional 2.3

ID: FR3                                                        
TITLE: User log-in.                                                              
DESC: Given that a user has registered, then the user should be able to log in to the web.                            
RAT: In order for a user to log in on the web.                                  
DEP: FR2

##### 3.2.2.1 Functional 2.4

ID: FR4                                                        
TITLE: Retrieve password.                                           
DESC: Given that a user has registered, then the user should be able to retrieve his/her password by e-
mail.                                                   
RAT: In order for a user to retrieve his/her password.                                              
DEP: FR2

##### 3.2.2.1 Functional 2.5

ID: FR5                                                    
TITLE: Search.                                                    
DESC: Given that a user is logged in to the web, one page that is shown should be
the All documents page. The user should be able to search for a document, according to several search options.
The search options are Date, Tag, Labelleds. A user should be able to select multiple search options in one search.            
RAT: In order for a user to search for a document.                               
DEP: FR3

##### 3.2.2.1 Functional 2.6

ID: FR6                                                
TITLE: Download.                                               
DESC: Given that a user is logged in to the web, one page that is shown should be
the All documents page. The user should be able to download for a document.                                   
DEP: FR3                                                 

##### 3.2.2.1 Functional 2.7

ID: FR7                                              
TITLE: My profile.                                       
DESC: Given that a user is logged in to the web, one page that is shown should be
the My profile page. The user should be able to edit his profile, being able to change his username, email and password. As well as you can request for an upgrade to admin.                                     
DEP: FR3

#### 3.2.3 User Class - Invited User

##### 3.2.3.1 Functional 3.1

ID: FR8                                         
TITLE: Invited log-in.                                        
DESC: The invited user should be able to log in to the web whitout given information.                             
RAT: In order for a invited user to log in on the web.                                       
DEP: FR2


##### 3.2.4 User Class 4 - The Admin 

##### 3.2.4.1 Functional 4.1

ID: FR9                
TITLE: Upload a document.                 
DESC: As an admin, I want to upload a document. To archive it I will need a PDF file, the tags refers to the document and label the users involucrated.
RAT: In order for an admin to upload a document.              
DEP: FR1

##### 3.2.4.2 Functional 4.2

ID: FR10                 
TITLE: Edit.                                                                                     
DESC: An admin, want to edit any document that has already been uploaded. He can can add or delete somo tags, add or delete labelled users.                                             
RAT: In order for an admin to edit uploaded documents.                                                             
DEP: FR9                                          

##### 3.2.4.3 Functional 4.3

ID: FR11                                                      
TITLE: Delete documents.                                                     
DESC: An admin, he should be able to delete a document that have been wrongfully uploaded, or for some reason are no longer important.                                                
RAT: In order for an admin to delete documents, no questions asked.                                                 
DEP: FR9

##### 3.2.4.4 Functional 4.4

ID: FR12                                               
TITLE: Accept other admins.                                         
DESC: As an admin, I have to accept when a normal user wants to become a admin user, this need the aprovation of 3 admin users at least.                                                
RAT: In order for an admin to accept a normal user to become an admin.                                             
DEP: FR7


### 3.3 Desing Requirements
The requirements in this section provide a detailed specification of the user interaction with the software
and measurements placed on the system performance.

#### 3.3.1 Search

ID: DR1                 
TITLE: Simple search feature                   
DESC: The search feature should be simple and easy for the user to use.
RAT: In order for the user to easily find the search feature and have no issues using it.                   
DEP: None.

#### 3.3.2 Document visualization 

ID: DR2               
TITLE: Simple document visualization                 
DESC: All documents should be easily identifiable, and ready to be read by clicking on them.                 
RAT: In order for the user to easily indetify and read the documents.     
DEP: None. 

#### 3.3.3 Document download

ID: DR3               
TITLE: Simple download feature             
DESC: All documents should be easily downloaded by clicking on a download icon.       
RAT: In order for the user to easily download any document.             

#### 3.3.4 Suscribing 

ID: DR4             
TITLE: Ease of subscribing/unsuscribing to an IC         
DESC: All ICs should be listed on the user's profile so that they can easily subscribe to any of them by checking a small box next to the ICs name, or unsubscribe by doing the exact opposite.                                
RAT: In order for the user to easily subscribe/unsubscribe to an IC.      

#### 3.3.5 Log-In & Register

ID: DR5            
TITLE: Easy log-in and register service.        
DESC: The users should be able to log-in and register in the web on a easy way.                                
RAT: In order for the user to easily log-in/register to the service. 

#### 3.3.6 Notifications

ID: DR6            
TITLE: Simple notificaions.        
DESC: The notifications should be simple and only contain the necessary information.                                
RAT: In order for the user can read easily the notifications.

#### 3.4 Design Constraints

This section includes the design constraints on the software caused by the hardware.

##### 3.4.1 Docs 

ID: DC1              
TITLE: Having the docs in your computer              
DESC: The admin must have the document's PDF file stored in his computer in order to be able to upload it, any other kinds of storage will not work (URLs, etc).

##### 3.4.2 E-mail

ID: DC2                           
TITLE: Having an email account                     
DESC: The system is designed so that all users must have an email account.

##### 3.4.3 ID

ID: DC3           
TITLE: Having an ID number               
DESC: Only people with ID numbers will be able to sign up for an account.



