/* Custom Template for input field
   Used in Vlocity Dynamic Form to override the default input template
*/

vlocity.cardframework.registerModule.controller('customActionsController', ['$scope', function($scope) {
    // $scope.$parent.$parent.records contain the reference to field object passed from VDF
    $scope.field = $scope.$parent.$parent.records;
    
    $scope.autoGenerate = function() {
        //Integrate the external service here if needed
        $scope.field.userValues = '4154152222';
    };
    
    $scope.reset = function() {
        $scope.field.userValues = '';
    };
}]);