SELECT     DISTINCT
			dbo.PROJECTS.project_name
			, dbo.PROJECTS.project_version
			,*
--, dbo.BUILD_REQUEST_COMPONENTS.component_option
--, dbo.BUILD_REQUEST_COMPONENTS.build_deployed
--, dbo.BUILD_REQUEST_COMPONENTS.date_deployed
--, dbo.BUILD_REQUEST_COMPONENTS.status
--, dbo.BUILD_REQUESTS.build_request_id
FROM         dbo.BUILD_REQUESTS INNER JOIN
                      dbo.BUILD_REQUEST_COMPONENTS ON 
                      dbo.BUILD_REQUESTS.build_request_id = dbo.BUILD_REQUEST_COMPONENTS.build_request_id INNER JOIN
                      dbo.ENVIRONMENT ON dbo.BUILD_REQUESTS.environment_id = dbo.ENVIRONMENT.environment_id INNER JOIN
                      dbo.PROJECTS ON dbo.BUILD_REQUESTS.project_id = dbo.PROJECTS.project_id
 INNER JOIN components c ON pc.component_id = c.component_id
 
(
SELECT	c.component_name DatabaseName
		,dbaadmin.dbo.dbaudf_ConcatenateUnique(QUOTENAME(p.project_name + ' ' + p.project_version))
FROM gears.dbo.project_components pc
INNER JOIN gears.dbo.PROJECTS p ON pc.project_id = p.project_id 
INNER JOIN gears.dbo.components c ON pc.component_id = c.component_id
INNER JOIN gears.dbo.component_type ct on c.component_type_id = ct.component_type_id
WHERE ct.component_type = 'DB'
GROUP BY c.component_name
)

SELECT	DISTINCT
		p.project_name + ' ' + p.project_version
FROM	gears.dbo.PROJECTS p