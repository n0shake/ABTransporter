# ABTransporter

Simple helper class for NSURLSession upload and data tasks.

### Features:

1. Call WebServices using a single line of code
2. Handle callback easily through completion block
3. Check response and time information easily

Currently, the following commonly used settings have been set:

Content-Type : Application/JSON    
HTTPMethod : POST Method

### Calling the WebService

#### Upload Task : 

    [ABMainTransporter uploadDataWebServiceWithInputDictionary:parameters
                                          andWebServicePath:webServicePath
   	withCompletionBlock:^(NSData *data, NSError *error, NSURLResponse *response{
         
        }];

``inputDictionary``

Your input in dictionary format

``webServicePath``

Your WebService path in NSString format

``self``

Instance of class where UICompletionMethod and ExecutionMethod resides

``completionBlock``

Completion block with NSData, NSError, NSURLResponse as return values (Same values returned by NSURLSessionDataTask)

### Data Task :

	[ABMainTransporter dataWebServicewithWebServicePath:path
 	withCompletionBlock:^(NSData *data, NSError *error, NSURLResponse *response{
         
        }];
                
You can easily check the following things in the console:

Just write the respective codeblock before you call your WebService.
        
- Logger

		[ABMainTransporter setLogger];
