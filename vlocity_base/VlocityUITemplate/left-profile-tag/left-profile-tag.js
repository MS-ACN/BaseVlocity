vlocity.cardframework.registerModule
    .controller('viaProfileController',
                ['$scope', '$rootScope', '$timeout', function($scope, $rootScope, $timeout) {

      function initProfiler() {
          if (!$Lightning) {
            $timeout(initProfiler, 2000);
          }
          if ($Lightning) {
              var nsPrefix = localStorage.getItem('nsPrefixDotNotation')
              var lightningNsPrefix = nsPrefix.substring(0, nsPrefix.length - 1) + ':';
              var ltngOutVFComponentName = lightningNsPrefix + "ltngOutVF";
              var profileTopLevelContainerViewComponentName = lightningNsPrefix + "profileTopLevelContainerView";

              $Lightning.use(ltngOutVFComponentName, function() {
                $Lightning.createComponent(profileTopLevelContainerViewComponentName,
                  { entityId : $rootScope.accountId},
                  "lightning-profiler",
                  function(cmp) {
                  });
              });

          }
      }

      initProfiler();

    }]);