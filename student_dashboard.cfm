<cfif not session.loggedIn>
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<!--- Get top 10 students by percentage --->
<cfquery name="topStudents" datasource="student_management">
    SELECT s.*, st.stream_name, c.college_name
    FROM students s
    LEFT JOIN streams st ON s.stream_id = st.stream_id
    LEFT JOIN colleges c ON s.college_id = c.college_id
    ORDER BY s.percentage DESC
    LIMIT 10
</cfquery>

<!--- Get year-wise pass/fail statistics --->
<cfquery name="yearWiseStats" datasource="student_management">
    SELECT 
        admission_year,
        COUNT(*) as total_students,
        SUM(CASE WHEN status = 'Pass' THEN 1 ELSE 0 END) as pass_count,
        SUM(CASE WHEN status = 'Fail' THEN 1 ELSE 0 END) as fail_count,
        ROUND((SUM(CASE WHEN status = 'Pass' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as pass_percentage
    FROM students
    WHERE admission_year IS NOT NULL
    GROUP BY admission_year
    ORDER BY admission_year DESC
</cfquery>

<!--- Get stream-wise statistics --->
<cfquery name="streamStats" datasource="student_management">
    SELECT 
        st.stream_name,
        COUNT(s.student_id) as student_count,
        AVG(s.percentage) as avg_percentage
    FROM streams st
    LEFT JOIN students s ON st.stream_id = s.stream_id
    GROUP BY st.stream_id, st.stream_name
    ORDER BY student_count DESC
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard - Analytics</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stats-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #007bff; }
        .stats-card h3 { margin-top: 0; color: #333; }
        .stats-card .number { font-size: 2em; font-weight: bold; color: #007bff; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #007bff; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        .chart-container { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .chart-bar { background-color: #007bff; height: 20px; border-radius: 10px; margin: 5px 0; position: relative; }
        .chart-bar-fill { background-color: #28a745; height: 100%; border-radius: 10px; }
        .chart-label { margin-bottom: 5px; font-weight: bold; }
        .chart-value { position: absolute; right: 10px; top: 0; line-height: 20px; color: white; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Student Dashboard</h1>
            <a href="index.cfm" class="btn">Back to Home</a>
        </div>
        
        <!--- Statistics Cards --->
        <div class="stats-grid">
            <div class="stats-card">
                <h3>Total Students</h3>
                <div class="number">
                    <cfquery name="totalStudents" datasource="student_management">
                        SELECT COUNT(*) as count FROM students
                    </cfquery>
                    <cfoutput>#totalStudents.count#</cfoutput>
                </div>
            </div>
            <div class="stats-card">
                <h3>Average Percentage</h3>
                <div class="number">
                    <cfquery name="avgPercentage" datasource="student_management">
                        SELECT AVG(percentage) as avg_perc FROM students WHERE percentage IS NOT NULL
                    </cfquery>
                    <cfoutput>#numberFormat(avgPercentage.avg_perc, "0.0")#%</cfoutput>
                </div>
            </div>
            <div class="stats-card">
                <h3>Pass Rate</h3>
                <div class="number">
                    <cfquery name="passRate" datasource="student_management">
                        SELECT 
                            (SUM(CASE WHEN status = 'Pass' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as pass_rate
                        FROM students
                    </cfquery>
                    <cfoutput>#numberFormat(passRate.pass_rate, "0.0")#%</cfoutput>
                </div>
            </div>
            <div class="stats-card">
                <h3>Active Streams</h3>
                <div class="number">
                    <cfoutput>#streamStats.recordCount#</cfoutput>
                </div>
            </div>
        </div>
        
        <!--- Top 10 Students --->
        <div class="chart-container">
            <h2>Top 10 Students by Percentage</h2>
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Stream</th>
                        <th>College</th>
                        <th>Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <cfset rank = 1>
                    <cfloop query="topStudents">
                        <tr>
                            <td><cfoutput>#rank#</cfoutput></td>
                            <td><cfoutput>#first_name# #last_name#</cfoutput></td>
                            <td><cfoutput>#email#</cfoutput></td>
                            <td><cfoutput>#stream_name#</cfoutput></td>
                            <td><cfoutput>#college_name#</cfoutput></td>
                            <td><cfoutput>#percentage#%</cfoutput></td>
                        </tr>
                        <cfset rank = rank + 1>
                    </cfloop>
                </tbody>
            </table>
        </div>
        
        <!--- Year-wise Pass/Fail Analysis --->
        <div class="chart-container">
            <h2>Year-wise Pass/Fail Analysis</h2>
            <table>
                <thead>
                    <tr>
                        <th>Year</th>
                        <th>Total Students</th>
                        <th>Passed</th>
                        <th>Failed</th>
                        <th>Pass Percentage</th>
                        <th>Visual</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop query="yearWiseStats">
                        <tr>
                            <td><cfoutput>#admission_year#</cfoutput></td>
                            <td><cfoutput>#total_students#</cfoutput></td>
                            <td><cfoutput>#pass_count#</cfoutput></td>
                            <td><cfoutput>#fail_count#</cfoutput></td>
                            <td><cfoutput>#pass_percentage#%</cfoutput></td>
                            <td>
                                <div class="chart-bar" style="width: 200px;">
                                    <div class="chart-bar-fill" style="width: <cfoutput>#pass_percentage#%</cfoutput>;">
                                        <span class="chart-value"><cfoutput>#pass_percentage#%</cfoutput></span>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
        </div>
        
        <!--- Stream-wise Analysis --->
        <div class="chart-container">
            <h2>Stream-wise Student Distribution</h2>
            <table>
                <thead>
                    <tr>
                        <th>Stream</th>
                        <th>Student Count</th>
                        <th>Average Percentage</th>
                        <th>Distribution</th>
                    </tr>
                </thead>
                <tbody>
                    <cfquery name="maxCount" datasource="student_management">
                        SELECT MAX(student_count) as max_count FROM (
                            SELECT COUNT(s.student_id) as student_count
                            FROM streams st
                            LEFT JOIN students s ON st.stream_id = s.stream_id
                            GROUP BY st.stream_id
                        ) as counts
                    </cfquery>
                    
                    <cfloop query="streamStats">
                        <tr>
                            <td><cfoutput>#stream_name#</cfoutput></td>
                            <td><cfoutput>#student_count#</cfoutput></td>
                            <td><cfoutput>#numberFormat(avg_percentage, "0.0")#%</cfoutput></td>
                            <td>
                                <div class="chart-bar" style="width: 200px;">
                                    <cfset percentage = (student_count / maxCount.max_count) * 100>
                                    <div class="chart-bar-fill" style="width: <cfoutput>#percentage#%</cfoutput>;">
                                        <span class="chart-value"><cfoutput>#student_count#</cfoutput></span>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
