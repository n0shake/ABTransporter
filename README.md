# ABTransporter
Simple wrapper class for NSURLSession upload and data tasks.

### Features:

1. Call WebServices using a single line of code
2. Define callback methods. No need for checking delegate methods
3. Check response and time information easily

Currently, the following commonly used settings have been set:

Content-Type : Application/JSON    
HTTPMethod : POST Method

### Calling the WebService

### Upload Task : (When your WebService needs to send some input)

	[ABMainTransporter uploadDataWebServiceWithInputDictionary:inputDictionary
                                          andWebServicePath:webServicePath
                                                   bySender:self
                                 withUICompletionMethodName:interfaceSelector
                           andExecutionMethodCompletionName:executionSelector];

``inputDictionary``

Your input in dictionary format

``webServicePath``

Your WebService path in NSString format

``self``

Instance of class where UICompletionMethod and ExecutionMethod resides

``interfaceSelector``

Method name in string format which will be performed on the main thread

``executionSelector``

Method name in string format. Perform all non UIKit related tasks here.

_You can pass nil to interfaceSelector and executionSelector if you want to._

### Data Task : (When your WebService does not have any input)


	[ABMainTransporter dataWebServicewithWebServicePath:path
                                   bySender:self
 				withUICompletionMethodName:interfaceSelector                       		   andExecutionMethodCompletionName:executionSelector];
                
### Upload Task : (When you want to do error handling)


- Initialize ABMainTransporter (for e.g. ``webService`` here)

- Set the errorSelector

- Set the UISelector

- Set the executionSelector

- And write the following line:

		[webService errorHandlingUploadWebServicewithInput:inputDictionary
                                     andWebServicePath:IMGUPLOAD_PATH
                                              bySender:self];

You can easily check the following things in the console:

Just write the respective codeblock before you call your WebService.

- Time Logger

		[ABMainTransporter setTimeLogger];

- Response Logger

		[ABMainTransporter setResponseLogger];
        
- Logger [Provides both time and response information]

		[ABMainTransporter setLogger];





