import ballerina/http;
import nalaka/firestore;

configurable string serviceAccountPath = ?;
configurable string privateKey = ?;


firestore:Client firestoreClient = check initFirestoreClient();


function initFirestoreClient() returns firestore:Client|error {
    firestore:AuthConfig authConfig = {
        serviceAccountPath: serviceAccountPath,
        privateKeyPath: privateKey,
        jwtConfig: {
            scope: "https://www.googleapis.com/auth/datastore",
            expTime: 3600 
        }
    };
    return new(authConfig);
}

service / on new http:Listener(9090) {
    resource function get .() returns string{
        return "Hello from ballerina";
    }
   resource function post user(@http:Payload json payload) returns firestore:OperationResult|error {
        string? Name = check payload.name.ensureType();
        string? Age = check payload.age.ensureType();
        map<json> userData = {
            "name": Name,
            "age" : Age
        };
        
        firestore:OperationResult|error result =  firestoreClient.add("users", userData);
        
        return result;
    }
}
