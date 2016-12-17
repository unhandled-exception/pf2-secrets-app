$(function(){
  Validator = (function() {
    function Validator() {}

    Validator.prototype.trim = function(str) {
      var ref;
      return str != null ? (ref = str.replace(/^\s+/, "")) != null ? ref.replace(/\s+$/, "") : void 0 : void 0;
    };

    Validator.prototype.check_form = function(objects, submitters) {
      var el, i, len;
      this.checker = function() {
        var el, good, i, j, len, len1, total;
        good = total = 0;
        for (i = 0, len = objects.length; i < len; i++) {
          el = objects[i];
          if (Validator.prototype.trim($(el).val())) {
            good += 1;
          }
          total += 1;
        }
        good = good === total;
        for (j = 0, len1 = submitters.length; j < len1; j++) {
          el = submitters[j];
          if (good) {
            $(el).removeAttr("disabled");
          } else {
            $(el).attr("disabled", "true");
          }
        }
      };
      this.checker();
      for (i = 0, len = objects.length; i < len; i++) {
        el = objects[i];
        $(el).keyup(this.checker).change(this.checker);
      }
      setTimeout(this.checker, 1000);
      return this;
    };

    return Validator;

  })();

  validator = new Validator();
});
