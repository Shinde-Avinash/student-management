<cfparam name="form.username" default="">
<cfparam name="form.password" default="">
<cfparam name="form.email" default="">
<cfset message = "">
<cfset success = false>

<cfif structKeyExists(form, "submit")>
    <cftry>
        <!--- Check if username already exists --->
        <cfquery name="checkUser" datasource="student_management">
            SELECT user_id FROM users
            WHERE username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
            OR email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif checkUser.recordCount>
            <cfset message = "Username or email already exists">
        <cfelse>
            <!--- Insert new user --->
            <cfquery datasource="student_management">
                INSERT INTO users (username, password, email, role)
                VALUES (
                    <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                    'student'
                )
            </cfquery>
            <cfset success = true>
            <cfset message = "Account created successfully! You can now login.">
        </cfif>
        
        <cfcatch type="any">
            <cfset message = "Registration error: " & cfcatch.message>
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Sign Up - Student Management</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .signup-container { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 400px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        .btn { background-color: #28a745; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; width: 100%; font-size: 16px; }
        .btn:hover { background-color: #218838; }
        .error { color: #dc3545; margin-bottom: 15px; text-align: center; }
        .success { color: #28a745; margin-bottom: 15px; text-align: center; }
        .links { text-align: center; margin-top: 20px; }
        .links a { color: #007bff; text-decoration: none; }
        h2 { text-align: center; margin-bottom: 30px; color: #333; }
    </style>
</head>
<body>
    <div class="signup-container">
        <h2>Sign Up</h2>
        
        <cfif len(message)>
            <div class="<cfif success>success<cfelse>error</cfif>"><cfoutput>#message#</cfoutput></div>
        </cfif>
        
        <cfif not success>
            <form method="post">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" name="username" id="username" value="<cfoutput>#form.username#</cfoutput>" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" name="email" id="email" value="<cfoutput>#form.email#</cfoutput>" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" name="password" id="password" required>
                </div>
                
                <button type="submit" name="submit" class="btn">Sign Up</button>
            </form>
        </cfif>
        
        <div class="links">
            <a href="login.cfm">Already have an account? Login</a><br>
            <a href="index.cfm">Back to Home</a>
        </div>
    </div>
</body>
</html>

