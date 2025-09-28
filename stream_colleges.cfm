<cfif not session.loggedIn>
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<cfparam name="url.stream_id" default="">

<!--- Get all streams --->
<cfquery name="getStreams" datasource="student_management">
    SELECT stream_id, stream_name, description FROM streams ORDER BY stream_name
</cfquery>

<!--- Get colleges by stream --->
<cfif len(url.stream_id)>
    <!--- Get top 10 colleges for selected stream --->
    <cfquery name="getColleges" datasource="student_management">
        SELECT * FROM colleges 
        WHERE stream_id = <cfqueryparam value="#url.stream_id#" cfsqltype="cf_sql_integer">
        ORDER BY rating DESC, placement_percentage DESC
        LIMIT 10
    </cfquery>
    
    <!--- Get placement data for colleges --->
    <cfquery name="getPlacementData" datasource="student_management">
        SELECT cp.*, c.college_name
        FROM college_placements cp
        INNER JOIN colleges c ON cp.college_id = c.college_id
        WHERE c.stream_id = <cfqueryparam value="#url.stream_id#" cfsqltype="cf_sql_integer">
        ORDER BY c.college_name, cp.year DESC
    </cfquery>
    
    <!--- Get selected stream info --->
    <cfquery name="selectedStream" datasource="student_management">
        SELECT stream_name, description FROM streams 
        WHERE stream_id = <cfqueryparam value="#url.stream_id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Stream-wise College Information</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; margin: 5px; }
        .btn:hover { background-color: #0056b3; }
        .stream-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stream-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #007bff; cursor: pointer; transition: all 0.3s; }
        .stream-card:hover { background: #e9ecef; transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .stream-card h3 { margin-top: 0; color: #007bff; }
        .college-card { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #28a745; }
        .college-header { display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px; }
        .college-name { color: #28a745; margin: 0; }
        .rating { background: #ffc107; color: #000; padding: 5px 10px; border-radius: 15px; font-weight: bold; }
        .college-details { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 15px; }
        .detail-item { display: flex; justify-content: space-between; padding: 5px 0; border-bottom: 1px solid #dee2e6; }
        .placement-chart { background: white; padding: 15px; border-radius: 5px; margin-top: 15px; }
        .chart-bar { background-color: #e9ecef; height: 25px; border-radius: 12px; margin: 8px 0; position: relative; overflow: hidden; }
        .chart-bar-fill { background: linear-gradient(90deg, #28a745, #20c997); height: 100%; border-radius: 12px; transition: width 0.8s ease; }
        .chart-label { font-size: 12px; font-weight: bold; margin-bottom: 3px; }
        .chart-value { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); color: white; font-size: 12px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #007bff; color: white; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        .back-link { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Stream-wise College Information</h1>
            <a href="index.cfm" class="btn">Back to Home</a>
        </div>
        
        <cfif not len(url.stream_id)>
            <!--- Display all streams --->
            <h2>Select a Stream to View Colleges</h2>
            <div class="stream-grid">
                <cfloop query="getStreams">
                    <div class="stream-card" onclick="location.href='stream_colleges.cfm?stream_id=<cfoutput>#stream_id#</cfoutput>'">
                        <h3><cfoutput>#stream_name#</cfoutput></h3>
                        <p><cfoutput>#description#</cfoutput></p>
                        
                        <!--- Get college count for this stream --->
                        <cfquery name="collegeCount" datasource="student_management">
                            SELECT COUNT(*) as count FROM colleges WHERE stream_id = <cfqueryparam value="#stream_id#" cfsqltype="cf_sql_integer">
                        </cfquery>
                        <p><strong>Colleges Available: <cfoutput>#collegeCount.count#</cfoutput></strong></p>
                    </div>
                </cfloop>
            </div>
        <cfelse>
            <!--- Display colleges for selected stream --->
            <div class="back-link">
                <a href="stream_colleges.cfm" class="btn">← Back to All Streams</a>
            </div>
            
            <cfif selectedStream.recordCount>
                <h2><cfoutput>#selectedStream.stream_name# - Top Colleges</cfoutput></h2>
                <p><cfoutput>#selectedStream.description#</cfoutput></p>
            </cfif>
            
            <cfif getColleges.recordCount>
                <cfloop query="getColleges">
                    <div class="college-card">
                        <div class="college-header">
                            <h3 class="college-name"><cfoutput>#college_name#</cfoutput></h3>
                            <div class="rating">★ <cfoutput>#rating#</cfoutput></div>
                        </div>
                        
                        <div class="college-details">
                            <div>
                                <div class="detail-item">
                                    <span><strong>Location:</strong></span>
                                    <span><cfoutput>#location#</cfoutput></span>
                                </div>
                                <div class="detail-item">
                                    <span><strong>Established:</strong></span>
                                    <span><cfoutput>#established_year#</cfoutput></span>
                                </div>
                                <div class="detail-item">
                                    <span><strong>Fees:</strong></span>
                                    <span>₹<cfoutput>#numberFormat(fees, "9,99,999")#</cfoutput></span>
                                </div>
                            </div>
                            <div>
                                <div class="detail-item">
                                    <span><strong>Placement Rate:</strong></span>
                                    <span><cfoutput>#placement_percentage#%</cfoutput></span>
                                </div>
                                <div class="detail-item">
                                    <span><strong>Email:</strong></span>
                                    <span><cfoutput>#contact_email#</cfoutput></span>
                                </div>
                                <div class="detail-item">
                                    <span><strong>Phone:</strong></span>
                                    <span><cfoutput>#contact_phone#</cfoutput></span>
                                </div>
                            </div>
                        </div>
                        
                        <p><cfoutput>#description#</cfoutput></p>
                        
                        <!--- Placement trend for this college --->
                        <cfquery name="collegePlacementTrend" datasource="student_management">
                            SELECT year, placement_percentage, placed_students, total_students, average_package
                            FROM college_placements
                            WHERE college_id = <cfqueryparam value="#college_id#" cfsqltype="cf_sql_integer">
                            ORDER BY year DESC
                            LIMIT 3
                        </cfquery>
                        
                        <cfif collegePlacementTrend.recordCount>
                            <div class="placement-chart">
                                <h4>Recent Placement Trends</h4>
                                <cfloop query="collegePlacementTrend">
                                    <div class="chart-label">
                                        <cfoutput>#year# - #placed_students#/#total_students# students (Avg: ₹#numberFormat(average_package/100000, "0.0")#L)</cfoutput>
                                    </div>
                                    <div class="chart-bar">
                                        <div class="chart-bar-fill" style="width: <cfoutput>#placement_percentage#%</cfoutput>;">
                                            <span class="chart-value"><cfoutput>#placement_percentage#%</cfoutput></span>
                                        </div>
                                    </div>
                                </cfloop>
                            </div>
                        </cfif>
                        
                        <cfif len(website)>
                            <div style="margin-top: 15px;">
                                <a href="http://<cfoutput>#website#</cfoutput>" target="_blank" class="btn">Visit Website</a>
                                <a href="college_selection.cfm?college_id=<cfoutput>#college_id#</cfoutput>" class="btn">View Details</a>
                            </div>
                        </cfif>
                    </div>
                </cfloop>
                
                <!--- Year-wise placement summary table --->
                <cfif getPlacementData.recordCount>
                    <h3>Year-wise Placement Analysis</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>College</th>
                                <th>Year</th>
                                <th>Total Students</th>
                                <th>Placed</th>
                                <th>Placement %</th>
                                <th>Average Package</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="getPlacementData">
                                <tr>
                                    <td><cfoutput>#college_name#</cfoutput></td>
                                    <td><cfoutput>#year#</cfoutput></td>
                                    <td><cfoutput>#total_students#</cfoutput></td>
                                    <td><cfoutput>#placed_students#</cfoutput></td>
                                    <td><cfoutput>#placement_percentage#%</cfoutput></td>
                                    <td>₹<cfoutput>#numberFormat(average_package, "9,99,999")#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </cfif>
            <cfelse>
                <p>No colleges found for this stream.</p>
            </cfif>
        </cfif>
    </div>
</body>
</html>
