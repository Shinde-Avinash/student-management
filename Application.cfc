<!--- Application.cfc with Direct Database Configuration --->
<cfcomponent displayname="Application" output="false" hint="Handle the application with direct DB setup.">
    <cfset this.name = "StudentManagement">
    <cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
    <cfset this.setClientCookies = true>
    <cfset this.setDomainCookies = false>
    <cfset this.scriptProtect = "all">
    
    <!--- Database Configuration - Update these values for your MySQL setup --->
    <cfset this.datasources = {}>
    <cfset this.datasources["student_management"] = {
        class: 'com.mysql.cj.jdbc.Driver',
        bundleName: 'com.mysql.cj',
        bundleVersion: '8.0.33',
        connectionString: 'jdbc:mysql://localhost:3306/student_management?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true',
        username: 'avi10',
        password: 'avi10',
        
        <!--- Connection pool settings --->
        connectionLimit: 100,
        liveTimeout: 60,
        alwaysSetTimeout: true,
        validate: false
    }>
    
    <!--- Set the default datasource --->
    <cfset this.datasource = "student_management">
    
    <!--- MySQL JDBC Driver Setup for Lucee --->
    <cfset this.javaSettings = {
        loadPaths: ["./drivers/"],
        loadColdFusionClassPath: true,
        reloadOnChange: false
    }>
    
    <cffunction name="onApplicationStart" returnType="boolean" output="false">
        <cftry>
            <!--- Test database connection --->
            <cfquery name="testConnection" datasource="student_management">
                SELECT 1 as test
            </cfquery>
            
            <!--- Set application variables --->
            <cfset application.appName = "Student Management System">
            <cfset application.version = "1.0">
            <cfset application.startTime = now()>
            
            <cflog file="application" text="Application started successfully. Database connection verified.">
            <cfreturn true>
            
            <cfcatch type="any">
                <cflog file="application" text="Application start failed: #cfcatch.message#">
                <!--- You can uncomment the line below to see detailed error info --->
                <!--- <cfdump var="#cfcatch#"><cfabort> --->
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="onSessionStart" returnType="void" output="false">
        <cfset session.loggedIn = false>
        <cfset session.username = "">
        <cfset session.userId = "">
        <cfset session.userRole = "">
        <cfset session.startTime = now()>
    </cffunction>
    
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <cfargument name="targetPage" type="String" required="true">
        
        <!--- Force application restart if URL parameter is passed --->
        <cfif structKeyExists(url, "reinit") and url.reinit eq "true">
            <cfset this.onApplicationStart()>
        </cfif>
        
        <!--- Set request timeout --->
        <cfsetting requestTimeout="30">
        
        <!--- Initialize session variables if they don't exist --->
        <cfif not structKeyExists(session, "loggedIn")>
            <cfset session.loggedIn = false>
            <cfset session.username = "">
            <cfset session.userId = "">
            <cfset session.userRole = "">
        </cfif>
        
        <cfreturn true>
    </cffunction>
    
    <cffunction name="onError" returnType="void" output="true">
        <cfargument name="exception" required="true">
        <cfargument name="eventName" type="String" required="true">
        
        <!--- Log the error --->
        <cflog file="application_errors" text="Error in #arguments.eventName#: #arguments.exception.message#">
        
        <!--- Display user-friendly error page --->
        <cfheader statuscode="500" statustext="Internal Server Error">
        <cfoutput>
            <!DOCTYPE html>
            <html>
            <head>
                <title>System Error</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 50px; background-color: ##f8f9fa; }
                    .error-container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }
                    .error-title { color: ##dc3545; margin-bottom: 20px; }
                    .error-message { background: ##f8d7da; color: ##721c24; padding: 15px; border-radius: 5px; border: 1px solid ##f5c6cb; margin-bottom: 20px; }
                    .btn { background-color: ##007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; }
                    .debug-info { background: ##f8f9fa; padding: 15px; border-radius: 5px; margin-top: 20px; font-family: monospace; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="error-container">
                    <h2 class="error-title">System Error Occurred</h2>
                    <div class="error-message">
                        <strong>Error:</strong> #arguments.exception.message#
                    </div>
                    <p>We're sorry, but something went wrong. Please try again or contact the administrator.</p>
                    <a href="index.cfm" class="btn">Return to Home</a>
                    
                    <!--- Show debug info in development (remove in production) --->
                    <cfif isDefined("url.debug") and url.debug eq "true">
                        <div class="debug-info">
                            <strong>Debug Information:</strong><br>
                            <strong>File:</strong> #arguments.exception.tagContext[1].template#<br>
                            <strong>Line:</strong> #arguments.exception.tagContext[1].line#<br>
                            <strong>Detail:</strong> #arguments.exception.detail#
                        </div>
                    </cfif>
                </div>
            </body>
            </html>
        </cfoutput>
    </cffunction>
</cfcomponent>