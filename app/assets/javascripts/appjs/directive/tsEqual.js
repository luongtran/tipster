TS.directive('tsEqual', [
  function() {
    return {
      restrict: 'A',
      scope: {
        classLink: '@'
      },
      link: function(scope, elm, attrs) {

        // find element unit follow class
        var listUnit = elm[0].querySelectorAll('.'+scope.classLink);
        console.log(listUnit);
        if (listUnit.length > 1) {
          scope.$watch(
            function() {
              var equalHeight = 0;
              angular.forEach(listUnit, function(cb,i) {
                var unitHeight = angular.element(cb).innerHeight();
                if (unitHeight > equalHeight) equalHeight = unitHeight;
              });
              return equalHeight;
            },
            function(n,o) {
              if (n!=void 0 && n!=null) {
                angular.element(listUnit).css('height', n);
              }
            }
          );
        }

      }
    };
  }
]);