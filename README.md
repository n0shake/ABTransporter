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

#### Upload Task : (When your WebService needs to send some input; uses NSURLSessionUploadTask)

	[ABMainTransporter uploadDataWebServiceWithInputDictionary:inputDictionary
                                          andWebServicePath:webServicePath
                                        withCompletionBlock:completionBlock];

``inputDictionary``

Your input in dictionary format

``webServicePath``

Your WebService path in NSString format

``self``

Instance of class where UICompletionMethod and ExecutionMethod resides

``completionBlock``

Completion block with NSData, NSError, NSURLResponse as return values (Same values returned by NSURLSessionDataTask)

### Data Task : (When your WebService does not have any input; uses NSURLSessionDataTask)


	[ABMainTransporter dataWebServicewithWebServicePath:path
 				withCompletionBlock:completionBlock];
                
You can easily check the following things in the console:

Just write the respective codeblock before you call your WebService.

- Time Logger

		[ABMainTransporter setTimeLogger];

- Response Logger

		[ABMainTransporter setResponseLogger];
        
- Logger [Provides both time and response information]

		[ABMainTransporter setLogger];
