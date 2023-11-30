import ballerina/http;

configurable int port = 8080;

// Definicja klasy użytkownika
type User readonly & record {|
    string id;
    string email;
    string password;
|};

// Predefiniowani użytkownicy
table<User> key(id) users = table [
    {id: "1", email: "user1@example.com", password: "password1"},
    {id: "2", email: "user2@example.com", password: "password2"},
    {id: "3", email: "user3@example.com", password: "password3"}
];

// Rozpoczęcie serwisu HTTP
service / on new http:Listener(port) {
    // Pobiera listę wszystkich użytkowników
    resource function get users() returns User[] {
        return users.toArray();
    }

    // Pobiera pojedynczego użytkownika o określonym identyfikatorze
    resource function get users/[string id]() returns User|http:NotFound {
        User? user = users[id];
        if user is () {
            return http:NOT_FOUND;
        } else {
            return user;
        }
    }

    // Dodaje nowego użytkownika
    resource function post users(@http:Payload User user) returns User {
        users.add(user);
        return user;
    }

    // Resetuje hasło użytkownika na podstawie adresu e-mail
    resource function post users/resetPassword(@http:Payload string email) returns json {
        User? existingUser = getUserByEmail(email);

        if (existingUser is ()) {
            // Użytkownik o podanym adresie e-mail nie istnieje
            return {
                "code": "400",
                "message": "Bad Request"
            };
        } else {
            // Użytkownik o podanym adresie e-mail istnieje
            return {
                "code": "200",
                "message": "Accepted"
            };
        }
      }

      resource function post auth/login(@http:Payload UserCredentials credentials) returns json {
        User? user = authenticateUser(credentials);

        if (user is ()) {
            // Prawidłowa kombinacja e-maila i hasła
            return {
                "code": "401",
                "message": "Unauthorized"
                
            };
        } else {
            // Nieprawidłowa kombinacja e-maila i hasła
            return {
                "code": "200",
                "message": "OK"
            };
        }
    }

}

// Funkcja pomocnicza do pobierania użytkownika na podstawie adresu e-mail
function getUserByEmail(string email) returns User? {
    // Iterujemy po wszystkich użytkownikach w tabeli
    foreach var user in users {
        if (user.email == email) {
            // Zwracamy użytkownika, jeśli adres e-mail pasuje
            return user;
        }
    }
    // Jeśli nie znaleziono użytkownika, zwracamy null
    return ();
}

// Funkcja pomocnicza do uwierzytelniania użytkownika
function authenticateUser(UserCredentials credentials) returns User? {
    // Iterujemy po wszystkich użytkownikach w tabeli
    foreach var user in users {
        if (user.email == credentials.email && user.password == credentials.password) {
            // Zwracamy użytkownika, jeśli kombinacja e-maila i hasła jest prawidłowa
            return user;
        }
    }
    // Jeśli nie znaleziono użytkownika, zwracamy null
    return ();
}

// Nowy typ danych do przechowywania danych uwierzytelniających
type UserCredentials record {
    string email;
    string password;
};


