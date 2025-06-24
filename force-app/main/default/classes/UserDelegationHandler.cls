public class UserDelegationHandler {
	
	@AuraEnabled(cacheable=true)
	public static detailWrapper getActiveDelegationAccess() {
        detailWrapper resultWrapper = new detailWrapper();
		
		resultWrapper.lstOfActiveDelagationAccess = [SELECT Id, Name, Start_Date__c, End_Date__c, Request_Type__c 
																	FROM Delegation_Request__c 
																	WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY];
       
		system.debug('lstOfActiveDelagationAccess??? '+resultWrapper.lstOfActiveDelagationAccess);
        List<PermissionSetAssignment> permissionSet = [SELECT Id, Assignee.Name, PermissionSet.Name 
                                        FROM PermissionSetAssignment 
                                        WHERE Assignee.Name =: UserInfo.getName() 
                                        // AND PermissionSet.Name = 'Delegated_Search_Permission_Set'
                                        LIMIT 1];
        resultWrapper.isPermissionSetAssigned = !permissionSet.isEmpty();

        resultWrapper.lstOfUser = [SELECT Id, Name FROM User];
        system.debug('resultWrapper??? '+resultWrapper);
		return resultWrapper;
	}

    @AuraEnabled
    public static List<User> queryCloneFrom() {
        User currentUser = [
            SELECT UserRoleId 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];

        if (currentUser.UserRoleId == null) {
            return new List<User>();
        }

        Set<Id> descendantRoleIds = new Set<Id>();
        collectChildRoleIds(currentUser.UserRoleId, descendantRoleIds);

        if (descendantRoleIds.isEmpty()) {
            return new List<User>();
        }

        return [
            SELECT Id, Name 
            FROM User 
            WHERE IsActive = true
            AND UserRoleId IN :descendantRoleIds
            ORDER BY Name
        ];
    }

    private static void collectChildRoleIds(Id parentRoleId, Set<Id> collectedRoleIds) {
        List<UserRole> childRoles = [
            SELECT Id 
            FROM UserRole 
            WHERE ParentRoleId = :parentRoleId
        ];

        for (UserRole role : childRoles) {
            collectedRoleIds.add(role.Id);
            collectChildRoleIds(role.Id, collectedRoleIds);
        }
    }
	/*
    @AuraEnabled
    public static List<User> getSubordinateUsersBySearchKey(String searchKey) {
		system.debug('searchKey??? '+searchKey);
        if (String.isBlank(searchKey)) {
            return new List<User>();
        }

        User matchedUser = [
            SELECT Id, Name, UserRoleId
            FROM User
            WHERE Name = :searchKey
            LIMIT 1
        ];
		system.debug('matchedUser?? '+matchedUser);
        if (matchedUser == null || String.isBlank(matchedUser.UserRoleId)) {
			system.debug('81');
            return new List<User>();
        }

        Set<Id> descendantRoleIds = new Set<Id>();
		getSubordinateRoleIds(matchedUser.UserRoleId, descendantRoleIds);

        if (descendantRoleIds.isEmpty()) {
			system.debug('88');
            return new List<User>();
        }

        return [
            SELECT Id, Name, Email, UserRoleId
            FROM User
            WHERE UserRoleId IN :descendantRoleIds
        ];
    }

    private static void getSubordinateRoleIds(Id parentRoleId, Set<Id> collectedRoleIds) {
        List<UserRole> childRoles = [
            SELECT Id 
            FROM UserRole 
            WHERE ParentRoleId = :parentRoleId
        ];

        for (UserRole role : childRoles) {
            collectedRoleIds.add(role.Id);
            collectChildRoleIds(role.Id, collectedRoleIds);
        }
    }
	*/

    public class detailWrapper {
        @AuraEnabled public List<Delegation_Request__c> lstOfActiveDelagationAccess;
        @AuraEnabled public Boolean isPermissionSetAssigned;
        @AuraEnabled public List<User> lstOfUser;
        
    }

}