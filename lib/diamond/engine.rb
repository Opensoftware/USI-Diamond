module Diamond
  class Engine < ::Rails::Engine
    isolate_namespace Diamond

    def navigation(primary, context)

      primary.item :nav, context.t(:label_thesis_plural), context.diamond.theses_path do |primary|
        primary.item :nav, context.t(:label_new), context.diamond.new_thesis_path
        if thesis = context.instance_variable_get("@thesis")
          primary.item :nav, thesis.title, lambda { context.diamond.thesis_path(thesis) }, :unless => Proc.new { thesis.new_record? }
          primary.item :nav, context.t(:label_edit), lambda { context.diamond.edit_thesis_path(thesis) }, :unless => Proc.new { thesis.new_record? }
        end
      end
    end
  end

end
