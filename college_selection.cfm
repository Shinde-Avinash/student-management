<cfif not session.loggedIn>
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<cfparam name="url.stream_id" default="">
<cfparam name="url.college_id" default="">

<!--- Get all streams for selection --->
<cfquery name="getStreams" datasource="student_management">
    SELECT stream_id, stream_name FROM streams ORDER BY stream_name
</cfquery>

<!--- Get colleges based on selected stream --->
<cfif len(url.stream_id)>
    <cfquery name="getColleges" datasource="student_management">
        SELECT * FROM colleges 
        WHERE stream_id = <cfqueryparam value="#url.stream_id#" cfsqltype="cf_sql_integer">
        ORDER BY rating DESC, placement_percentage DESC
    </cfquery>
    
    <cfquery name="selectedStream" datasource="student_management">
        SELECT stream_name FROM streams 
        WHERE stream_id = <cfqueryparam value="#url.stream_id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<!--- Get detailed college information --->
<cfif len(url.college_id)>
    <cfquery name="collegeDetails" datasource="student_management">
        SELECT c.*, s.stream_name
        FROM colleges c
        INNER JOIN streams s ON c.stream_id = s.stream_id
        WHERE c.college_id = <cfqueryparam value="#url.college_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfquery name="collegePlacement" datasource="student_management">
        SELECT * FROM college_placements
        WHERE college_id = <cfqueryparam value="#url.college_id#" cfsqltype="cf_sql_integer">
        ORDER BY year DESC
    </cfquery>
    
    <!--- Get students from this college --->
    <cfquery name="collegeStudents" datasource="student_management">
        SELECT COUNT(*) as student_count, AVG(percentage) as avg_percentage
        FROM students
        WHERE college_id = <cfqueryparam value="#url.college_id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>College Selection for Admission</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; margin: 5px; }
        .btn-success { background-color: #28a745; }
        .btn:hover { opacity: 0.9; }
        .selection-form { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .college-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 20px; }
        .college-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #28a745; transition: all 0.3s; cursor: pointer; }
        .college-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .college-name { color: #28a745; margin-bottom: 10px; }
        .college-info { margin-bottom: 15px; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 8px; padding-bottom: 5px; border-bottom: 1px solid #dee2e6; }
        .rating { background: #ffc107; color: #000; padding: 3px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .detailed-view { background: white; border: 1px solid #ddd; border-radius: 8px; padding: 30px; margin-top: 20px; }
        .detail-section { margin-bottom: 30px; }
        .detail-section h3 { color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 15px; border-radius: 8px; text-align: center; }
        .stat-number { font-size: 2em; font-weight: bold; color: #007bff; }
        .stat-label { color: #6c757d; font-size: 0.9em; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #007bff; color: white; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        .breadcrumb { margin-bottom: 20px; color: #6c757d; }
        .breadcrumb a { color: #007bff; text-decoration: none; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>College Selection for Admission</h1>
            <a href="index.cfm" class="btn">Back to Home</a>
        </div>
        
        <cfif len(url.college_id)>
            <!--- Detailed College View --->
            <div class="breadcrumb">
                <a href="college_selection.cfm">All Streams</a> > 
                <a href="college_selection.cfm?stream_id=<cfoutput>#collegeDetails.stream_id#</cfoutput>"><cfoutput>#collegeDetails.stream_name#</cfoutput></a> > 
                <cfoutput>#collegeDetails.college_name#</cfoutput>
            </div>
            
            <cfif collegeDetails.recordCount>
                <div class="detailed-view">
                    <div class="detail-section">
                        <h2 style="color: #28a745; margin-bottom: 10px;"><cfoutput>#collegeDetails.college_name#</cfoutput></h2>
                        <div class="rating" style="display: inline-block; margin-bottom: 20px;">★ <cfoutput>#collegeDetails.rating#</cfoutput> Rating</div>
                        <p style="font-size: 1.1em; line-height: 1.6;"><cfoutput>#collegeDetails.description#</cfoutput></p>
                    </div>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-number"><cfoutput>#collegeDetails.established_year#</cfoutput></div>
                            <div class="stat-label">Established</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">₹<cfoutput>#numberFormat(collegeDetails.fees/100000, "0.0")#L</cfoutput></div>
                            <div class="stat-label">Annual Fees</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number"><cfoutput>#collegeDetails.placement_percentage#%</cfoutput></div>
                            <div class="stat-label">Placement Rate</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number"><cfoutput>#collegeStudents.student_count#</cfoutput></div>
                            <div class="stat-label">Current Students</div>
                        </div>
                    </div>
                    
                    <div class="detail-section">
                        <h3>Contact Information</h3>
                        <div class="info-row">
                            <span><strong>Location:</strong></span>
                            <span><cfoutput>#collegeDetails.location#</cfoutput></span>
                        </div>
                        <div class="info-row">
                            <span><strong>Email:</strong></span>
                            <span><cfoutput>#collegeDetails.contact_email#</cfoutput></span>
                        </div>
                        <div class="info-row">
                            <span><strong>Phone:</strong></span>
                            <span><cfoutput>#collegeDetails.contact_phone#</cfoutput></span>
                        </div>
                        <div class="info-row">
                            <span><strong>Website:</strong></span>
                            <span><a href="http://<cfoutput>#collegeDetails.website#</cfoutput>" target="_blank"><cfoutput>#collegeDetails.website#</cfoutput></a></span>
                        </div>
                    </div>
                    
                    <cfif collegePlacement.recordCount>
                        <div class="detail-section">
                            <h3>Placement History</h3>
                            <table>
                                <thead>
                                    <tr>
                                        <th>Year</th>
                                        <th>Total Students</th>
                                        <th>Placed Students</th>
                                        <th>Placement Percentage</th>
                                        <th>Average Package</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop query="collegePlacement">
                                        <tr>
                                            <td><cfoutput>#year#</cfoutput></td>
                                            <td><cfoutput>#total_students#</cfoutput></td>
                                            <td><cfoutput>#placed_students#</cfoutput></td>
                                            <td><cfoutput>#placement_percentage#%</cfoutput></td>
                                            <td>₹<cfoutput>#numberFormat(average_package, "9,99,999")#</cfoutput></td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </cfif>
                    
                    <div class="detail-section">
                        <h3>Apply for Admission</h3>
                        <p>Interested in this college? Contact the admissions office for more information about the application process.</p>
                        <a href="mailto:<cfoutput>#collegeDetails.contact_email#</cfoutput>" class="btn btn-success">Contact Admissions</a>
                        <a href="http://<cfoutput>#collegeDetails.website#</cfoutput>" target="_blank" class="btn">Visit Website</a>
                    </div>
                </div>
            </cfif>
        
        <cfelseif len(url.stream_id)>
            <!--- College List for Selected Stream --->
            <div class="breadcrumb">
                <a href="college_selection.cfm">All Streams</a> > <cfoutput>#selectedStream.stream_name#</cfoutput>
            </div>
            
            <h2>Available Colleges - <cfoutput>#selectedStream.stream_name#</cfoutput></h2>
            
            <cfif getColleges.recordCount>
                <div class="college-grid">
                    <cfloop query="getColleges">
                        <div class="college-card" onclick="location.href='college_selection.cfm?college_id=<cfoutput>#college_id#</cfoutput>'">
                            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                                <h3 class="college-name"><cfoutput>#college_name#</cfoutput></h3>
                                <span class="rating">★ <cfoutput>#rating#</cfoutput></span>
                            </div>
                            
                            <div class="college-info">
                                <div class="info-row">
                                    <span><strong>Location:</strong></span>
                                    <span><cfoutput>#location#</cfoutput></span>
                                </div>
                                <div class="info-row">
                                    <span><strong>Established:</strong></span>
                                    <span><cfoutput>#established_year#</cfoutput></span>
                                </div>
                                <div class="info-row">
                                    <span><strong>Fees:</strong></span>
                                    <span>₹<cfoutput>#numberFormat(fees, "9,99,999")#</cfoutput></span>
                                </div>
                                <div class="info-row">
                                    <span><strong>Placement:</strong></span>
                                    <span><cfoutput>#placement_percentage#%</cfoutput></span>
                                </div>
                            </div>
                            
                            <p style="color: #6c757d; font-size: 0.9em; margin-bottom: 15px;">
                                <cfoutput>#left(description, 100)#</cfoutput><cfif len(description) gt 100>...</cfif>
                            </p>
                            
                            <div>
                                <span class="btn" style="font-size: 0.8em;">Click to View Details</span>
                            </div>
                        </div>
                    </cfloop>
                </div>
            <cfelse>
                <p>No colleges available for this stream.</p>
            </cfif>
        
        <cfelse>
            <!--- Stream Selection --->
            <div class="selection-form">
                <h2>Select Your Stream</h2>
                <p>Choose a stream to view available colleges for admission:</p>
                
                <form method="get">
                    <div class="form-group">
                        <label for="stream_id">Stream:</label>
                        <select name="stream_id" id="stream_id" onchange="this.form.submit()">
                            <option value="">-- Select Stream --</option>
                            <cfloop query="getStreams">
                                <option value="<cfoutput>#stream_id#</cfoutput>">
                                    <cfoutput>#stream_name#</cfoutput>
                                </option>
                            </cfloop>
                        </select>
                    </div>
                </form>
            </div>
            
            <!--- Stream Overview --->
            <h2>Available Streams</h2>
            <div class="college-grid">
                <cfloop query="getStreams">
                    <div class="college-card" onclick="location.href='college_selection.cfm?stream_id=<cfoutput>#stream_id#</cfoutput>'">
                        <h3 class="college-name"><cfoutput>#stream_name#</cfoutput></h3>
                        
                        <!--- Get college count and stats for this stream --->
                        <cfquery name="streamStats" datasource="student_management">
                            SELECT 
                                COUNT(*) as college_count,
                                AVG(rating) as avg_rating,
                                AVG(placement_percentage) as avg_placement,
                                MIN(fees) as min_fees,
                                MAX(fees) as max_fees
                            FROM colleges 
                            WHERE stream_id = <cfqueryparam value="#stream_id#" cfsqltype="cf_sql_integer">
                        </cfquery>
                        
                        <div class="college-info">
                            <div class="info-row">
                                <span><strong>Colleges:</strong></span>
                                <span><cfoutput>#streamStats.college_count#</cfoutput></span>
                            </div>
                            <div class="info-row">
                                <span><strong>Avg Rating:</strong></span>
                                <span>★ <cfoutput>#numberFormat(streamStats.avg_rating, "0.0")#</cfoutput></span>
                            </div>
                            <div class="info-row">
                                <span><strong>Avg Placement:</strong></span>
                                <span><cfoutput>#numberFormat(streamStats.avg_placement, "0.0")#%</cfoutput></span>
                            </div>
                            <div class="info-row">
                                <span><strong>Fee Range:</strong></span>
                                <span>₹<cfoutput>#numberFormat(streamStats.min_fees/100000, "0.0")#L - #numberFormat(streamStats.max_fees/100000, "0.0")#L</cfoutput></span>
                            </div>
                        </div>
                        
                        <div style="margin-top: 15px;">
                            <span class="btn" style="font-size: 0.8em;">Explore Colleges</span>
                        </div>
                    </div>
                </cfloop>
            </div>
        </cfif>
    </div>
</body>
</html>