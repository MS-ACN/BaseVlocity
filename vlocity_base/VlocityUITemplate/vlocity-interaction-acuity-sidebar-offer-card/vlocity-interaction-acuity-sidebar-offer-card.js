vlocity.cardframework.registerModule
    .controller('viaAcuitySidebarOfferCard',
                ['$scope', '$timeout', function($scope, $timeout) {
        this.getImageUrl = function(obj) {
            if (!obj) {
                return null;
            }
            var imageId = null;
            Object.keys(obj.attachment).forEach(function(key) {
                if (!imageId) {
                    imageId = obj.attachment[key];
                }
                if (/@sidebar/.test(key)) {
                    imageId = obj.attachment[key];
                    return false;
                }
            });
            return '/servlet/servlet.FileDownload?file=' +imageId;
        };

        this.getTags = function(obj) {
            if (!obj || !angular.isArray(obj.componentScores)) {
                return [];
            }
            return obj.componentScores.reduce(function(array, componentScore) {
                if (componentScore && angular.isArray(componentScore.scoreParameters)) {
                    return array.concat(componentScore.scoreParameters);
                }
                return array;
            }, []);
        };

        function registerLightningEventHandler() {
            if (typeof $A === 'undefined') {
                $timeout(registerLightningEventHandler, 1000);
                return;
            }
            var lightningNsPrefix = $scope.nsPrefix.replace('__', ':'),
                collectedChanges = [];
            $A.eventService.addHandler({
                "event": lightningNsPrefix + "profileAttributeValueUpdatedEvent",
                "handler": function(event) {
                    $scope.$parent.$parent.$parent.sObjects = null;
                    $scope.reloadCard();
                }
            });

            $A.eventService.addHandler({
                "event": lightningNsPrefix + "profileAttributeCategoryUpdatedEvent",
                "handler": function(event) {
                    collectedChanges.push(event);
                }
            });
            
            $A.eventService.addHandler({
                "event": lightningNsPrefix + "profileNavigationEvent",
                "handler": function(event) {
                    var navigateFrom = event.getParam('navigateFrom'),
                        navigateTo = event.getParam('navigateTo');
                    if (navigateFrom === 'slide-to-profiler-edit' && collectedChanges.length > 0) {
                        $scope.$parent.$parent.$parent.sObjects = null;
                        $scope.reloadCard();
                    } else {
                        collectedChanges = [];
                    }
                }
            });
        }

        registerLightningEventHandler();

    }]);