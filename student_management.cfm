<cfif not session.loggedIn or session.userRole neq "admin">
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<cfparam name="url.action" default="">
<cfparam name="url.id" default="">
<cfparam name="form.search" default="">
<cfset message = "">

<!--- Handle CRUD Operations --->
<cfswitch expression="#url.action#">
    <cfcase value="delete">
        <cftry>
            <cfquery datasource="student_management">
                DELETE FROM students WHERE student_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset message = "Student deleted successfully">
            <cfcatch type="any">
                <cfset message = "Error deleting student: " & cfcatch.message>
            </cfcatch>
        </cftry>
    </cfcase>
</cfswitch>

<!--- Handle Add/Update Student --->
<cfif structKeyExists(form, "submit")>
    <cftry>
        <cfif len(form.student_id)>
            <!--- Update Student --->
            <cfquery datasource="student_management">
                UPDATE students SET
                    first_name = <cfqueryparam value="#form.first_name#" cfsqltype="cf_sql_varchar">,
                    last_name = <cfqueryparam value="#form.last_name#" cfsqltype="cf_sql_varchar">,
                    email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                    phone = <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">,
                    date_of_birth = <cfqueryparam value="#form.date_of_birth#" cfsqltype="cf_sql_date">,
                    gender = <cfqueryparam value="#form.gender#" cfsqltype="cf_sql_varchar">,
                    address = <cfqueryparam value="#form.address#" cfsqltype="cf_sql_longvarchar">,
                    admission_year = <cfqueryparam value="#form.admission_year#" cfsqltype="cf_sql_integer">,
                    stream_id = <cfqueryparam value="#form.stream_id#" cfsqltype="cf_sql_integer">,
                    college_id = <cfqueryparam value="#form.college_id#" cfsqltype="cf_sql_integer">,
                    total_marks = <cfqueryparam value="#form.total_marks#" cfsqltype="cf_sql_decimal">,
                    percentage = <cfqueryparam value="#form.percentage#" cfsqltype="cf_sql_decimal">,
                    status = <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">
                WHERE student_id = <cfqueryparam value="#form.student_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset message = "Student updated successfully">
        <cfelse>
            <!--- Add Student --->
            <cfquery datasource="student_management">
                INSERT INTO students (first_name, last_name, email, phone, date_of_birth, gender, address, admission_year, stream_id, college_id, total_marks, percentage, status)
                VALUES (
                    <cfqueryparam value="#form.first_name#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.last_name#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.date_of_birth#" cfsqltype="cf_sql_date">,
                    <cfqueryparam value="#form.gender#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#form.address#" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="#form.admission_year#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#form.stream_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#form.college_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#form.total_marks#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.percentage#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            <cfset message = "Student added successfully">
        </cfif>
        
        <cfcatch type="any">
            <cfset message = "Error saving student: " & cfcatch.message>
        </cfcatch>
    </cftry>
</cfif>

<!--- Get student data for editing --->
<cfif url.action eq "edit" and len(url.id)>
    <cfquery name="getStudent" datasource="student_management">
        SELECT * FROM students WHERE student_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<!--- Get all streams for dropdown --->
<cfquery name="getStreams" datasource="student_management">
    SELECT stream_id, stream_name FROM streams ORDER BY stream_name
</cfquery>

<!--- Get all colleges for dropdown --->
<cfquery name="getColleges" datasource="student_management">
    SELECT college_id, college_name FROM colleges ORDER BY college_name
</cfquery>

<!--- Search and display students --->
<cfquery name="getStudents" datasource="student_management">
    SELECT s.*, st.stream_name, c.college_name
    FROM students s
    LEFT JOIN streams st ON s.stream_id = st.stream_id
    LEFT JOIN colleges c ON s.college_id = c.college_id
    <cfif len(trim(form.search))>
        WHERE s.first_name LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
        OR s.last_name LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
        OR s.email LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
    </cfif>
    ORDER BY s.student_id DESC
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>Student Management - Admin Panel</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-success { background-color: #28a745; }
        .btn-danger { background-color: #dc3545; }
        .btn-warning { background-color: #ffc107; color: #212529; }
        .btn:hover { opacity: 0.9; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .form-row { display: flex; gap: 15px; }
        .form-row .form-group { flex: 1; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f8f9fa; font-weight: bold; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        .message { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .message.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .search-form { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-form input { flex: 1; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Student Management</h1>
            <div>
                <a href="index.cfm" class="btn">Back to Dashboard</a>
                <button onclick="toggleForm()" class="btn btn-success">Add New Student</button>
            </div>
        </div>
        
        <cfif len(message)>
            <div class="message success"><cfoutput>#message#</cfoutput></div>
        </cfif>
        
        <!--- Student Form --->
        <div id="studentForm" style="display: <cfif url.action eq 'edit'>block<cfelse>none</cfif>;">
            <h3><cfif url.action eq "edit">Edit Student<cfelse>Add New Student</cfif></h3>
            <form method="post">
                <cfif url.action eq "edit" and isDefined("getStudent") and getStudent.recordCount>
                    <input type="hidden" name="student_id" value="<cfoutput>#getStudent.student_id#</cfoutput>">
                </cfif>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="first_name">First Name:</label>
                        <input type="text" name="first_name" id="first_name" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.first_name#</cfoutput></cfif>" required>
                    </div>
                    <div class="form-group">
                        <label for="last_name">Last Name:</label>
                        <input type="text" name="last_name" id="last_name" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.last_name#</cfoutput></cfif>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" name="email" id="email" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.email#</cfoutput></cfif>" required>
                    </div>
                    <div class="form-group">
                        <label for="phone">Phone:</label>
                        <input type="text" name="phone" id="phone" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.phone#</cfoutput></cfif>">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="date_of_birth">Date of Birth:</label>
                        <input type="date" name="date_of_birth" id="date_of_birth" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#dateFormat(getStudent.date_of_birth, 'yyyy-mm-dd')#</cfoutput></cfif>">
                    </div>
                    <div class="form-group">
                        <label for="gender">Gender:</label>
                        <select name="gender" id="gender">
                            <option value="">Select Gender</option>
                            <option value="Male" <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.gender eq 'Male'>selected</cfif>>Male</option>
                            <option value="Female" <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.gender eq 'Female'>selected</cfif>>Female</option>
                            <option value="Other" <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.gender eq 'Other'>selected</cfif>>Other</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="address">Address:</label>
                    <textarea name="address" id="address" rows="3"><cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.address#</cfoutput></cfif></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="admission_year">Admission Year:</label>
                        <input type="number" name="admission_year" id="admission_year" min="2010" max="2030" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.admission_year#</cfoutput></cfif>">
                    </div>
                    <div class="form-group">
                        <label for="stream_id">Stream:</label>
                        <select name="stream_id" id="stream_id">
                            <option value="">Select Stream</option>
                            <cfloop query="getStreams">
                                <option value="<cfoutput>#stream_id#</cfoutput>" 
                                        <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.stream_id eq stream_id>selected</cfif>>
                                    <cfoutput>#stream_name#</cfoutput>
                                </option>
                            </cfloop>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="college_id">College:</label>
                        <select name="college_id" id="college_id">
                            <option value="">Select College</option>
                            <cfloop query="getColleges">
                                <option value="<cfoutput>#college_id#</cfoutput>" 
                                        <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.college_id eq college_id>selected</cfif>>
                                    <cfoutput>#college_name#</cfoutput>
                                </option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="total_marks">Total Marks:</label>
                        <input type="number" name="total_marks" id="total_marks" step="0.01" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.total_marks#</cfoutput></cfif>">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="percentage">Percentage:</label>
                        <input type="number" name="percentage" id="percentage" step="0.01" max="100" 
                               value="<cfif isDefined('getStudent') and getStudent.recordCount><cfoutput>#getStudent.percentage#</cfoutput></cfif>">
                    </div>
                    <div class="form-group">
                        <label for="status">Status:</label>
                        <select name="status" id="status">
                            <option value="Pass" <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.status eq 'Pass'>selected</cfif>>Pass</option>
                            <option value="Fail" <cfif isDefined('getStudent') and getStudent.recordCount and getStudent.status eq 'Fail'>selected</cfif>>Fail</option>
                        </select>
                    </div>
                </div>
                
                <div style="margin-top: 20px;">
                    <button type="submit" name="submit" class="btn btn-success">Save Student</button>
                    <button type="button" onclick="toggleForm()" class="btn">Cancel</button>
                </div>
            </form>
        </div>
        
        <!--- Search Form --->
        <form method="post" class="search-form">
            <input type="text" name="search" placeholder="Search students by name or email..." value="<cfoutput>#form.search#</cfoutput>">
            <button type="submit" class="btn">Search</button>
            <cfif len(trim(form.search))>
                <a href="student_management.cfm" class="btn">Clear</a>
            </cfif>
        </form>
        
        <!--- Students Table --->
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Stream</th>
                    <th>College</th>
                    <th>Percentage</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <cfif getStudents.recordCount>
                    <cfloop query="getStudents">
                        <tr>
                            <td><cfoutput>#student_id#</cfoutput></td>
                            <td><cfoutput>#first_name# #last_name#</cfoutput></td>
                            <td><cfoutput>#email#</cfoutput></td>
                            <td><cfoutput>#phone#</cfoutput></td>
                            <td><cfoutput>#stream_name#</cfoutput></td>
                            <td><cfoutput>#college_name#</cfoutput></td>
                            <td><cfoutput>#percentage#%</cfoutput></td>
                            <td><cfoutput>#status#</cfoutput></td>
                            <td>
                                <a href="student_management.cfm?action=edit&id=<cfoutput>#student_id#</cfoutput>" class="btn btn-warning" style="padding: 5px 10px; font-size: 12px;">Edit</a>
                                <a href="student_management.cfm?action=delete&id=<cfoutput>#student_id#</cfoutput>" 
                                   class="btn btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                   onclick="return confirm('Are you sure you want to delete this student?')">Delete</a>
                            </td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <tr>
                        <td colspan="9" style="text-align: center;">No students found</td>
                    </tr>
                </cfif>
            </tbody>
        </table>
    </div>
    
    <script>
        function toggleForm() {
            var form = document.getElementById('studentForm');
            if (form.style.display === 'none') {
                form.style.display = 'block';
            } else {
                form.style.display = 'none';
                // Clear form when hiding
                form.querySelector('form').reset();
            }
        }
    </script>
</body>
</html>
