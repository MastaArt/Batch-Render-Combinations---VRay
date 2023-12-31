/*  
[INFO] 
NAME = Batch Render Combinations VRay
VERSION = 1.0.5
AUTHOR = MastaMan
DEV = https://3dground.net
HELP = 
[1.0.0]
* Initial release =

[1.0.2]
+ Added: Cancel render process by ESC =

[1.0.3]
+ Added: Custom angles list =

[1.0.4]
- BugFix: Render unnecessary materials with digits in name=

[1.0.5]
* Changed: Now information stored in *.ini files=

[SCRIPT]
*/

try(closeRolloutFloater fBatchRenderCombinations) catch()
global fBatchRenderCombinations = newRolloutFloater "Batch Render Combinations VRay" 280 700

-- FileProperties based settings system
/*struct '$' (
    fn add n v = (
        return (fileProperties.addProperty #custom n v)
    ),
    fn get n = (
        i = fileProperties.findProperty #custom n
        if(i != 0) do (
            v = fileProperties.getPropertyValue #custom i
            if(v[1] == "#") do return execute(v)
            return v
        )
        return undefined
    ),
    fn del n = (
        fileProperties.deleteProperty #custom n
    ),
    fn list t: #full = (
        p = fileProperties.getNumProperties #custom
        res = #()
        for i in 1 to (fileProperties.getNumProperties #custom) do (
            n = fileProperties.getPropertyName #custom i
            v = fileProperties.getPropertyValue #custom i
            
            case t of (
                #names: append res n
                #values: append res v
                default: append res #(n, v)
            )
        )
        
        return res
    )	
)*/

struct '$' (
	fn hash = (
		return ((dotnetclass "System.Guid").NewGuid()).ToString()
	),	
    fn addFileProperty n v = (
        return (fileProperties.addProperty #custom n v)
    ),
    fn getFileProperty n = (
        local i = fileProperties.findProperty #custom n
        if(i != 0) do (
            v = fileProperties.getPropertyValue #custom i
            if(v[1] == "#") do return execute(v)
            return v
        )
        return undefined
    ),
    fn delFileProperty n = (
        fileProperties.deleteProperty #custom n
    ),
    fn listFileProperties t: #full = (
        p = fileProperties.getNumProperties #custom
        res = #()
        for i in 1 to (fileProperties.getNumProperties #custom) do (
            n = fileProperties.getPropertyName #custom i
            v = fileProperties.getPropertyValue #custom i
            
            case t of (
                #names: append res n
                #values: append res v
                default: append res #(n, v)
            )
        )
        
        return res
    ),
	
	fn checkGUID = (
		local id = getFileProperty "guid"
		if (id == undefined) do (
			id = hash()
			addFileProperty "guid" id
		)
		
		return id
	),
	
	fn getIniName id = (
		local p = getFilenamePath (getThisScriptFilename()) + @"combinations\"
		
		makeDir p all: true	
		return p + id + ".ini"
	),
	
	fn addSetting n v = (		
		local id = checkGUID()
		local ini = getIniName id
		
		setINISetting ini "SETTINGS" n (v as string)
	),
	
	fn getSetting n = (
		local id = checkGUID()		
		local ini = getIniName id
		return getINISetting ini "SETTINGS" n
	),
	
	fn clearList s = (
		local id = checkGUID()		
		local ini = getIniName id
		delINISetting ini s
	),
	
	fn addCombination c = (
		local id = checkGUID()		
		local ini = getIniName id
		local a = ""
		/*if (classOf c[2] != Array) do (
			setINISetting ini "COMBINATIONS" c[1] ""
			return false
		)*/
		
		clearList "COMBINATIONS"
		
		for i in c do (
			local a = ""
			for ii in i[2] do a += (ii as string) + "|"
			setINISetting ini "COMBINATIONS" i[1] a	
		)
	),
		
	fn getCombination n = (
		local id = checkGUID()		
		local ini = getIniName id
		local v = getINISetting ini "COMBINATIONS" b
		if (v == "") do return undefined
		return filterString v "|"
	),
	
	fn getCombinationsList = (
		local id = checkGUID()		
		local ini = getIniName id
		local v = getINISetting ini "COMBINATIONS"		
		
		local out = #()
		for i in v do (
			local vv = getIniSetting ini "COMBINATIONS" i
			append out #(i, filterString vv "|")
		)
		
		return out
	),
	
	fn addFrame c = (
		local id = checkGUID()		
		local ini = getIniName id
		
		clearList "FRAMES"
		
		for i in c do (
			setINISetting ini "FRAMES" (i[1] as string) (i[2] as string)
		)		
	),
	
	fn getFrame n  = (
		local id = checkGUID()		
		local ini = getIniName id
		local v = getINISetting ini "FRAMES" n
		if (v == "") do return undefined
		return v as integer
	),
	
	fn getFramesList = (
		local id = checkGUID()		
		local ini = getIniName id
		local v = getINISetting ini "FRAMES"
		local out = #()
		for i in v do (
			local vv = getIniSetting ini "FRAMES" i			
			vv = try (vv as integer) catch(0)
			append out #(i, vv)
		)
			
		return out
	),
	
	on create do (
		local id = checkGUID()
	)
)

rollout _rStepABB0  "Main"
(
    fn pickMaterialFilter obj = classOf obj == Sphere and obj.material != undefined 

	group "Views List (angles)" (	
		spinner spnAngle "Angle: " range: [-360, 360, 0] type: #integer align: #left fieldWidth: 70
		listbox lbxFramesList "" height: 6
		button btnAddFrame "Add" width: 100 across: 2 tooltip: "Create views by angle. You should have at least one angle.\nSettings are saved directly into the scene!"
        button btnRemoveFrame "Remove" width: 100
	)
	
    group "List Of Combinations" (
        listbox lbxCombinationsList "" height: 6
        button btnAddCombination "Add" width: 100 across: 2 tooltip: "Create combinations in a studio scene.\nSettings are saved directly into the scene!"
        button btnRemoveCombination "Remove" width: 100
    )

    group "Create Combinations" (
        --edittext edtModelPartName "Model Part Name: "
        edittext edtChangeMatName "Change Mat Name: "
        listbox lbxModelPartMaterials "Model Part Materials: " height: 6
        button btnAddMaterial "Add Materials +" width: 100 across: 2 filter: pickMaterialFilter message: "Please pick Sphere with material in the scene!" tooltip: "Pick Sphere with material in the studio scene."
        button btnRemoveMaterial "Remove Material" width: 100
    )

	group "Merge Models From" (
        edittext edtMergeModelPath "" readonly: true across: 2 align: #left fieldwidth: 195
        button btnMergeModelPath "..." width: 35  align: #right offset: [0, -3]
    )

    group "Save Output Renders" (
        edittext edtBatchRenderPath "" readonly: true across: 2 align: #left fieldwidth: 195
        button btnSetBatchRenderPath "..." width: 35  align: #right offset: [0, -3]
    )
    
    button btnStartRender "Start Batch Render" height: 35 width: 240 offset: [0, 10]
    
    fn getSaveDir type: "jpg" = (
        type = (toUpper type) +" (*." + type + ")|*." + type
        f = getSaveFileName filename: "DO NOT CHANGE NAME" caption:"Save File" types: type
        if(f == undefined) do return f
        
        p = getFileNamePath f
		
        return p
    )
	
    fn filterCombinations c = (
        if(c == undefined) do return #()
        return for i in c where c[1] != undefined collect i
    )
    
    fn getCombinations = (		
        c = ('$').getCombinationsList()
        return filterCombinations c
    )
    
    fn addCombination c = (
        ('$').addCombination c
    )
    
    fn removeFromArray c i = (
        if(i == 1 and c.count == 1) do return #()
        return for k in 1 to c.count where k != i collect c[k]
    )
    
    fn uiCreateCombinations n = (
        if(n == false) do (
            edtChangeMatName.text = ""
            lbxModelPartMaterials.items = #()
        )
        
        edtChangeMatName.enabled = n
        lbxModelPartMaterials.enabled = n
        btnAddMaterial.enabled = n
        btnRemoveMaterial.enabled = n
    )
    
    fn displayCombinationProps c id = (
        uiCreateCombinations false
        
        if(id == 0) do return false
        if(c.count == 0) do return false
        
        n = c[id][1]
        m = c[id][2]
        
        edtChangeMatName.text = n
        lbxModelPartMaterials.items = m
        uiCreateCombinations true
    )
	
	fn displayFrameProps c id = (
		if(id == 0) do return false
        if(c.count == 0) do return false
        
        n = c[id][1]
        v = c[id][2]
		
		spnAngle.value = (v as integer)
	)
	
    fn updateCombinaitonsList = (
        uiCreateCombinations false
        
        c = getCombinations()
		
        if(c.count > 0) do (
            names = #() 
            for i in c do (
                n = i[1]
                if(i[2].count == 0) do n += "   [Empty Materials]"
				
                append names n
             )
                 
            lbxCombinationsList.items = names
            lbxCombinationsList.selection = c.count
            displayCombinationProps c (c.count)
            return false
        )
        
        lbxCombinationsList.items = #()
    )
	
	fn getFrames = (		
        c = ('$').getFramesList()
        return filterCombinations c
    )
	
	
	fn updateFramesList = (
		local c = getFrames()
		
		if (c.count > 0) do (
			names = #() 
            for i in c do (
                local n = i[1]
				append names n
			)
			
			lbxFramesList.items = names
            lbxFramesList.selection = c.count
            displayFrameProps c (c.count)
            return true
		)
		
		spnAngle.value = 0
		lbxFramesList.items = #()
	)
    
	
	fn isUniqueSettingValue c v = (
		for i in c where i[2] == v do return false
		return true			
	)
	
	fn addNewFrame = (
		local s = '$'()
		
		local c = getFrames()
		
		local v = spnAngle.value
		local n = (v as string) + " deg"
		
		if (isUniqueSettingValue c v) then (
			append c #(n, v)
			s.addFrame c
			updateFramesList()
			return true
		)
		
		return messageBox "This angle already exists in list! Try another one..." title: "Warning!"
	)
	
	fn removeFrame = (
		local id = lbxFramesList.selection
		if(id == 0) do return messageBox "Please select item from list!" title: "Warning!"
		
		local s = '$'()
		
		c = getFrames()
        
        c = removeFromArray c id
        c = filterCombinations c
		
		s.addFrame c
		
		updateFramesList()
	)
    
    fn addNewCombination = (
        s = '$'()
        
        c = getCombinations()
        
        append c #("New Combination", #())
        c = filterCombinations c
		
        addCombination c
            
        updateCombinaitonsList()
    )
    
    fn removeCombination = (
        id = lbxCombinationsList.selection
            
        if(id == 0) do return messageBox "Please select combination from list!" title: "Warning!"
        
        q = queryBox ("Do you really want to delete combination \"" + lbxCombinationsList.selected + "\"") title: "Confirm?"
        if(not q) do return false
        
        c = getCombinations()	
        
        c = removeFromArray c id
        c = filterCombinations c
    
        addCombination c
        
        updateCombinaitonsList()
    )
    
    fn loadAdditionalSettings = (
        s = '$'()
        
        p1 = s.getSetting "MERGE_MODELS_PATH"
        if(p1 != undefined and doesFileExist p1) do edtMergeModelPath.text = p1
        
        p2 = s.getSetting "OUT_RENDER_PATH"
        if(p2 != undefined and doesFileExist p2) do edtBatchRenderPath.text = p2
    )
    
    on _rStepABB0 open do (
        uiCreateCombinations false
        
		local c = getFrames()
		if (c.count == 0) do (
			addNewFrame()
		)
		
        updateCombinaitonsList()
		updateFramesList()
        loadAdditionalSettings()
    )
	
    
    on btnAddCombination pressed do (
        addNewCombination()
        setFocus edtChangeMatName
    )
    
    on btnRemoveCombination pressed do (
        removeCombination()
    )
	
	on btnAddFrame pressed do (
		addNewFrame()
		setFocus spnAngle
	)
	
	on spnAngle entered v v2 do (
		addNewFrame()
		setFocus spnAngle
	)
	
	on btnRemoveFrame pressed do (
		removeFrame()
	)
    
    on lbxCombinationsList selected v do (
        id = lbxCombinationsList.selection
        c = getCombinations()
        uiCreateCombinations false
        
        if(c[id] == undefined) do return false
        
        displayCombinationProps c id
        
        uiCreateCombinations true
    )
	
	on lbxFramesList selected v do (
        local id = lbxFramesList.selection
        local c = getFrames()
        
        if(c[id] == undefined) do return false
        
        displayFrameProps c id        
    )
    
    on edtChangeMatName entered  v do (
        id = lbxCombinationsList.selection
        c = getCombinations()
        
        if(c[id] == undefined) do return false
        
        if(v.count < 3) do (
            edtChangeMatName.text = c[id][1]
            return messageBox "Please enter valid material name (min. 3 chars)" title: "Error!"
        )
		
        c[id][1] = v
        
        addCombination c
        
        updateCombinaitonsList()
        lbxCombinationsList.selection = id
        displayCombinationProps c id
    )
    
    on btnAddMaterial pressed do (
		local m = "Please select Spheres with Materials from the scene!\nFur Material will be added automatically!"
		if (selection.count == 0) do return messageBox m title: "Warning!"
		
		id = lbxCombinationsList.selection
        c = getCombinations()
        
        if(c[id] == undefined) do return false
		
		for i in selection where (classOf i == Sphere and i.material != undefined) do (
			n = i.name
			appendIfUnique c[id][2] n
		)
        
        addCombination c
        
        updateCombinaitonsList()
        lbxCombinationsList.selection = id
        displayCombinationProps c id
    )
    
    on btnRemoveMaterial pressed do (
        id = lbxCombinationsList.selection
        c = getCombinations()
        
        sid = lbxModelPartMaterials.selection
        
        if(sid == 0) do return messageBox "Please select material from list!" title: "Warning!"
        if(c[id] == undefined) do return false
        
        m = c[id][2]
        c[id][2] = removeFromArray m sid
        
        addCombination c
        
        updateCombinaitonsList()
        lbxCombinationsList.selection = id
        displayCombinationProps c id
    )
    
    on btnMergeModelPath pressed do (
        p = getSaveDir type: "max"
        if(p == undefined) do return false
        
        ('$').addSetting "MERGE_MODELS_PATH" p
        
        loadAdditionalSettings()
    )
    
    on btnSetBatchRenderPath pressed do (
        p = getSaveDir type: "png"
        if(p == undefined) do return false
        
        ('$').addSetting "OUT_RENDER_PATH" p
        
        loadAdditionalSettings()
    )
    
	fn getGroupFromSelection = (
		local p = #()
		for g in selection where isValidNode g do (
			if(isGroupHead g and not (isGroupMember g)) do return g
			
			if (g.parent != undefined and isGroupHead g.parent) do appendIfUnique p g.parent
		)
		
		-- If group is open
		local h = #()
		for i in p do (
			local x = i
			while x.parent != undefined do x = x.parent
			
			if(x != undefined and isGroupHead x and not (isGroupMember x)) do appendIfUnique h x
		)
		
		return h[1]
	)
	
	fn getGroupsListFromSelection = (
		local list = #()
		for g in selection where isValidNode g do (
			if(isGroupHead g and not (isGroupMember g)) do (
				if (isOpenGroupHead g) do setGroupOpen g false
				appendIfUnique list g	
			)
		)
		
		return list
	)
	
    fn isSupportedRender = (
        r = renderers.current
		
		if matchpattern (r as string) pattern:"*Corona*" do return #(r, "corona", "Corona")
		if matchpattern (r as string) pattern:"*V_Ray*" do return #(r, "vray", "VRay")
		    
        return undefined
    )
    
	fn getModelsPartsByMatName n = (
		return for i in (selection as array) where i.material != undefined and i.material.name == n collect i
	)
	
    fn getModelsParts n = (
        return for i in (objects as array) where (matchPattern (i.name) pattern: (n + "*")) collect i
    )
	
	fn getModelMaterials n = (
        return for i in (objects as array) where classOf i == Sphere and i.name == n collect i
    )

    fn forceUngroup o = (
        o = o as array
        if(o.count == 0) do return false

        for i in o where isGroupHead i and isValidNode i do explodeGroup i
    )
    
    fn forceDeleteObjects o = (
        o = o as array
        if(o.count == 0) do return false

        oo = for i in o where isValidNode i and not isDeleted i collect i
        delete oo
    )
	
	fn assignAllMaterialsFirst combinations = (		
		if(combinations.count == 0) do return false
		
		for i in combinations do (
			modelPartName = i[1]
			modelPartMaterials = i[2]
			
			modelParts = getModelsParts modelPartName
			
			select modelParts
            forceUngroup selection
            select modelParts
			
			if(modelParts.count == 0) do return false
				
			m = getModelMaterials modelPartMaterials[1]
			if(m == undefined or m.count == 0) do continue
			
			for iii in modelParts do iii.material = m[1].material			
		)
	)
	
	fn setupRender fileName isSelectedMode: false = (
		local r = isSupportedRender()
		
		deleteFile fileName
		
		if(renderSceneDialog.isOpen()) do renderSceneDialog.close() 		
		
		rendSaveFile = true
		rendOutputFilename = fileName
		rendTimeType = 1
		
		case r[2] of (
			"corona": (
				r[1].renderSelected_mode = if(isSelectedMode) then 1 else 0
				r[1].vfb_clearBetweenRenders = true
			)
			"vray": (
				r[1].system_previousRender = 5
				r[1].imageSampler_renderMask_type = if(isSelectedMode) then 2 else 0
				try (vfbcontrol #testresolution false) catch()
			)
		)
			
		reMgr = maxOps.getCurRenderElementMgr()
		reMgr.SetElementsActive false
		
		renderSceneDialog.commit()
		renderSceneDialog.update()
	)
    
    fn batchRender combinations pth modelName frame = (       
		if(combinations.count == 0) do (
			print ("Not found combinations for " + modelName + "\"!")
			return false
		)
		
        for i in combinations do (
            modelPartName = i[1]
            modelPartMaterials = i[2]
			
            modelParts = getModelsPartsByMatName modelPartName
			
            if(modelParts.count == 0) do (
                print ("Missing material \"" + modelPartName + "\" in \"" + modelName + "\"!")
                continue
            )
			
			local oldMaterials = for iii in modelParts where iii.material != undefined collect #(iii, iii.material)
			
            for ii in modelPartMaterials do (
                mats = getModelMaterials ii
                
                if(mats == undefined or mats.count == 0) do (
                    print ("Missing material \"" + ii + "\" for model part \"" + modelPartName + "\"!")
                    continue
				)
				
				for m in mats do (
					matName = m.name
					for iii in modelParts do iii.material = m.material
					
					tmp = pth + modelName + "_" + frame[1] + "_" + matName + ".png"
					
					setupRender tmp isSelectedMode: false
					
					print ("Render the " + tmp)
					
					max quick render
					
					if (getProgressCancel() or keyboard.escPressed) do (
						progressEnd()
						return false
					)
				)
            )
			
			for iii in oldMaterials do iii[1].material = iii[2]
        )
    )
	
	fn getCenterOfModel objs = (
		for i in objs where isGroupHead i do return i.pos
		return objs.center
	)
	
	fn addFileToScene f = (
		ext = getFileNameType f
		
		case ext of (
			".max": mergeMaxFile f #select #noRedraw #autoRenameDups #useMergedMtlDups quiet: true
			default: importFile f #noPrompt
		)		
	)
    
    on btnStartRender pressed do (
        cr = isSupportedRender()
        if(cr == undefined) do return messageBox "Please assign Corona or VRay Renderer!" title: "Error!"
		
		frames = getFrames()
		
		-- Inverse degs
		for i in frames do i[2] = i[2] * -1
		
		if(frames.count == 0) do return messageBox "Please add angles to Views List!" title: "Error!"
		
        origMaxFile = maxFilePath + maxFileName
		
        if(origMaxFile == "") do return messageBox "Please save the scene!" title: "Error!"
		
        checkForSave()
		
        s = ('$')
        p1 = s.getSetting "MERGE_MODELS_PATH"
        p2 = s.getSetting "OUT_RENDER_PATH"
        
        if(p1 == undefined or not doesFileExist p1) do return messageBox "Please choose Merge Models Path!" title: "Error!"
        if(p2 == undefined or not doesFileExist p2) do return messageBox "Please choose Save Output Render Path" title: "Error!"

        combinations = getCombinations()
		

        if(combinations.count == 0) do return messageBox "Please add Model Combinatons first!" title: "Error!"
        for i in combinations where i[1] == "New Combination" do return messageBox ("Please change name for combination \"New Combination\"\n\n Or remove this combination!") title: "Error!"
        for i in combinations where i[2].count == 0 do return messageBox ("Please add Model Part Materials for combination \"" + i[1] + "\"!\n\nOr remove this combination!") title: "Error!"
		
		
		if(frames.count == 0) do return messageBox "Please choose at least one view angle!" title: "Error!" 
		
		types = #("fbx", "max", "obj")
		files = #()
		for type in types do (
			join files (getFiles(p1 + "*." + type))
		)
    
        for i in 1 to files.count do (
			f = files[i]
			
            addFileToScene f
			
			progressStart "In process..."
			escapeEnable = true
			clearListener()
			
			local groups = getGroupsListFromSelection()
			if (groups.count == 0) do (
				print ("Not found groups for " + (getFilenameFile f) + "\"!")
				continue
			)
			
			clearSelection()
			
			select groups
			hide selection 
			
			out_folder = p2 + (getFilenameFile f) + @"\"
			makeDir out_folder all: true
			
			for g in 1 to groups.count do (
				local gg = groups[g]
				select gg
				unhide selection
				
				currentModel = #()
				currentModel = selection as array
				
				centerModel = getCenterOfModel selection
				
				modelName = getFilenameFile f
				
				-- Get name from group name
				local grp = getGroupFromSelection()
				if (grp != undefined) do (
					modelName = grp.name
				)
				
				pointHelper = point name: "ModelCenter" pos: centerModel
				
				for ss in currentModel do ss.parent = pointHelper
				
				for frame in frames do (
					if (getProgressCancel() or keyboard.escPressed) do (
						progressEnd()
						return false
					)
						
					pointHelper.rotation.z = 0
					rotate pointHelper (eulerAngles 0 0 frame[2])
					batchRender combinations out_folder modelName frame					
				)
				
				hide currentModel
				forceDeleteObjects currentModel
				delete pointHelper
				
				if (getProgressCancel() or keyboard.escPressed) do (
					progressEnd()
					return false
				)
				print "----"
				progressUpdate (100 * g / groups.count)
			)
            
			progressEnd()
        )
        
		q = queryBox "All combinations are rendered.\n\nDo you want to open the folder with renders?" title: "Confirm!"			
		if(q) do return  shellLaunch p2 ""
    )
)

rollout _rAboutABB "About" 
(
    label lblName "" 
    label lblVer "" 
    
    label lblAuthor "" height: 30
    hyperlink lblCopy ""  align: #center
    
    fn getScriptInfo s releaseInfo: "" =  (
        if(releaseInfo != "") do
        (
            r = getINISetting s releaseInfo
            return r
        )

        v = getINISetting s "INFO" "VERSION"
        a = getINISetting s "INFO" "AUTHOR"
        n = getINISetting s "INFO" "NAME"
        o = getINISetting s "ABOUT"
        c = getINISetting s "INFO" "DEV"
        h = getINISetting s "INFO" "HELP"
        
        r = for i in (getINISetting s) where (i != "ABOUT" and i != "SCRIPT" and i != "COPY") collect i
        
        return #(n, a, v, o, r, c, h)
    )

    on _rAboutABB open do
    (
        i = getScriptInfo (getThisScriptFilename())
	
        lblName.caption = i[1]
        lblAuthor.caption = i[2]
        lblVer.caption = i[3]
        lblCopy.address  = lblCopy.caption = i[6]
    )
)

addRollout _rStepABB0 fBatchRenderCombinations rolledUp:false
addRollout _rAboutABB fBatchRenderCombinations rolledUp:true 