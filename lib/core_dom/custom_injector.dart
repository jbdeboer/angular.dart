part of angular.core.dom_internal;

class CustomInjector implements Injector {
   final Injector _parent;
   final CustomModule _module;
    CustomInjector(this._parent, this._module) {
      _module.inj = this;
    }

   String get name => "CustomEBInjector";
   Injector get parent => _parent;
   Injector get root => _parent.root;
   Set<Type> get types { throw "type set not implemented"; }
   bool get allowImplicitInjection => false;
   dynamic get(Type type, [Type annotation]) {
     throw "get not implemented";
     if (annotation != null) {
       throw "annotations not impled: $annotation";
     }
     return _module.get(type);
   }

   dynamic getByKey(Key key) { return _module.get(key); }
   Injector createChild(List<Module> modules,
                       {List forceNewInstances, String name}) {
     if (forceNewInstances != null) throw "forceNewInstances not implemented";
     if (modules.length != 1) throw "only one module allowed";

     return new CustomInjector(this, modules[0]);
   }


}

_DEFAULT_VALUE(_) => null;

class CustomModule implements Module {
  var inj;

static Key ElementProbe_KEY = new Key(ElementProbe);
static Key NgIf_KEY = new Key(NgIf);
static Key AHref_KEY = new Key(AHref);
static Key NgInternalOptions_KEY = new Key(opts.NgInternalOptions);
static Key NgModel_KEY = new Key(NgModel);
static Key InputCheckbox_KEY = new Key(InputCheckbox);
static Key Scope_KEY = new Key(Scope);
static Key ViewCache_KEY = new Key(ViewCache);
static Key Http_KEY = new Key(Http);
static Key TemplateCache_KEY = new Key(TemplateCache);
static Key DirectiveMap_KEY = new Key(DirectiveMap);
static Key NgBaseCss_KEY = new Key(NgBaseCss);
static Key NodeTreeSanitizer_KEY = new Key(dom.NodeTreeSanitizer);
static Key WebPlatform_KEY = new Key(WebPlatform);
static Key ComponentCssRewriter_KEY = new Key(ComponentCssRewriter);
static Key EventHandler_KEY = new Key(EventHandler);
static Key BoundViewFactory_KEY = new Key(BoundViewFactory);
static Key ViewPort_KEY = new Key(ViewPort);
static Key Expando_KEY = new Key(Expando);
static Key ExceptionHandler_KEY = new Key(ExceptionHandler);
static Key FormatterMap_KEY = new Key(FormatterMap);
static Key Animate_KEY = new Key(Animate);
static Key NgControl_KEY = new Key(NgControl);
static Key NgModelOptions_KEY = new Key(NgModelOptions);
static Key TreeComponent_KEY = new Key(TreeComponent);
static Key TextMustache_KEY = new Key(TextMustache);
static Key Interpolate_KEY = new Key(Interpolate);

  static Key Element_KEY = new Key(dom.Element);
  static Key NodeAttrs_KEY = new Key(NodeAttrs);
  static Key View_KEY = new Key(View);
  static Key Node_KEY = new Key(dom.Node);
  static Key ViewFactory_KEY = new Key(ViewFactory);
  static Key TemplateLoader_KEY = new Key(TemplateLoader);
  static Key ShadowRoot_KEY = new Key(dom.ShadowRoot);
  static Key NgElement_KEY = new Key(NgElement);

  dynamic get(Key key) {
    if (key.id == ElementProbe_KEY.id) return elementProbe;
    if (key.id == NgIf_KEY.id) return ngIf;
    if (key.id == AHref_KEY.id) return aHref;
    if (key.id == NgInternalOptions_KEY.id) return ngInternalOptions;
    if (key.id == NgModel_KEY.id) return ngModel;
    if (key.id == InputCheckbox_KEY.id) return inputCheckbox;
    if (key.id == Scope_KEY.id) return scope;
    if (key.id == ViewCache_KEY.id) return viewCache;
    if (key.id == Http_KEY.id) return http;
    if (key.id == TemplateCache_KEY.id) return templateCache;
    if (key.id == DirectiveMap_KEY.id) return directiveMap;
    if (key.id == NgBaseCss_KEY.id) return ngBaseCss;
    if (key.id == NodeTreeSanitizer_KEY.id) return nodeTreeSanitizer;
    if (key.id == WebPlatform_KEY.id) return webPlatform;
    if (key.id == ComponentCssRewriter_KEY.id) return componentCssRewriter;
    if (key.id == EventHandler_KEY.id) return eventHandler;
    if (key.id == BoundViewFactory_KEY.id) return boundViewFactory;
    if (key.id == ViewPort_KEY.id) return viewPort;
    if (key.id == Expando_KEY.id) return expando;
    if (key.id == ExceptionHandler_KEY.id) return exceptionHandler;
    if (key.id == FormatterMap_KEY.id) return formatterMap;
    if (key.id == Animate_KEY.id) return animate;
    if (key.id == NgControl_KEY.id) return ngControl;
    if (key.id == NgModelOptions_KEY.id) return ngModelOptions;
    if (key.id == TreeComponent_KEY.id) return treeComponent;
    if (key.id == TextMustache_KEY.id) return textMustache;
    if (key.id == Interpolate_KEY.id) return interpolate;
    throw "not impled $key";
  }

  var element;
  var nodeAttrs;
  var view;
  var node;
  var viewFactory;
  var templateLoader;
  var shadowRoot;
  
  // instances
  var useBoundViewFactory = false;
  var factoryBoundViewFactory = (i) => i.parent.getByKey(BoundViewFactory_KEY);
  var _iBoundViewFactory;
  get boundViewFactory {
    return _iBoundViewFactory != null ? _iBoundViewFactory : _iBoundViewFactory = useBoundViewFactory ? null : factoryBoundViewFactory(inj);
  }

  var factoryElementProbe = (i) => i.parent.getByKey(ElementProbe_KEY);
  var _iElementProbe;
  get elementProbe => _iElementProbe != null ? _iElementProbe : _iElementProbe = factoryElementProbe(inj);

  var useViewPort = false;
  var factoryViewPort = (i) => i.parent.getByKey(ViewPort_KEY);
  var _iViewPort;
  get viewPort => _iViewPort != null || useViewPort ? _iViewPort : _iViewPort = factoryViewPort(inj);

  var useNgInternalOptions = false;
  var _iNgInternalOptions;
  var factoryNgInternalOptions;
  get ngInternalOptions => _iNgInternalOptions != null ? _iNgInternalOptions : _iNgInternalOptions = useNgInternalOptions ? new opts.NgInternalOptions() : factoryNgInternalOptions(inj);

  var useTreeComponent = false;
  var _iTreeComponent;
  var factoryTreeComponent = (i) => i.parent.getByKey(TreeComponent_KEY);
  get treeComponent => _iTreeComponent != null ? _iTreeComponent : _iTreeComponent = useTreeComponent ? new TreeComponent() : factoryTreeComponent(inj);

  var factoryTextMustache = (i) => i.parent.getByKey(TextMustache_KEY);
  var _iTextMustache;
  get textMustache => _iTextMustache != null ? _iTextMustache : _iTextMustache = factoryTextMustache(inj);
  
  

  var useNgIf = false;
  var _iNgIf;
  get ngIf => _iNgIf != null ? _iNgIf : _iNgIf = useNgIf ? new NgIf(boundViewFactory, viewPort, scope) : inj.parent.getByKey(NgIf_KEY);

  var useAHref = false;
  var _iAHref;
  get aHref => _iAHref != null ? _iAHref : _iAHref = useAHref ? new AHref(element, zone) : inj.parent.getByKey(AHref_KEY);

   var useNgModel = false;
  var _iNgModel;
  get ngModel => _iNgModel != null ? _iNgModel : _iNgModel = useNgModel ? new NgModel(scope, ngElement, inj, nodeAttrs, animate) : inj.parent.getByKey(NgModel_KEY);

  var useNgElement = false;
  var _iNgElement;
  get ngElement => _iNgElement != null ? _iNgElement : _iNgElement = useNgElement ? new NgElement(element, scope, animate) : inj.parent.getByKey(NgElement_KEY);

  var useInputCheckbox = false;
  var _iInputCheckbox;
  get inputCheckbox => _iInputCheckbox != null ? _iInputCheckbox : _iInputCheckbox = useInputCheckbox ? new InputCheckbox(element, ngModel, scope, ngTrueValue, ngFalseValue, ngModelOptions) : inj.parent.getByKey(InputCheckbox_KEY);

  var useEventHandler = false;
  var _iEventHandler;
  get eventHandler => _iEventHandler != null ? _iEventHandler : _iEventHandler = useEventHandler ? new EventHandler(node, expando, exceptionHandler) : inj.parent.getByKey(EventHandler_KEY);
  
  /*var _iNgNgTrueValue;
  get ngTrueValue => _iNgNgTrueValue != null ? _iNgNgTrueValue : new NgTrueValue(element);

  var _iNgNgFalseValue;
  get ngFalseValue => _iNgNgFalseValue != null ? _iNgNgFalseValue : new NgFalseValue(element);
  */
  
  var _iAnimate;
  get animate => _iAnimate != null ? _iAnimate : _iAnimate = inj.parent.getByKey(Animate_KEY);

  var _iScope;
  get scope => _iScope != null ? _iScope : _iScope = inj.parent.getByKey(Scope_KEY);

  var _iZone;
  get zone => _iZone != null ? _iZone : _iZone = inj.parent.getByKey(VmTurnZone_KEY);

  var _iNgModelOptions;
  get ngModelOptions => _iNgModelOptions != null ? _iNgModelOptions : _iNgModelOptions = inj.parent.getByKey(NgModelOptions_KEY);

  var _iViewCache;
  get viewCache => _iViewCache != null ? _iViewCache : _iViewCache = inj.parent.getByKey(ViewCache_KEY);

  var _iHttp;
  get http => _iHttp != null ? _iHttp : _iHttp = inj.parent.getByKey(Http_KEY);

  var _iTemplateCache;
  get templateCache => _iTemplateCache != null ? _iTemplateCache : _iTemplateCache = inj.parent.getByKey(TemplateCache_KEY);

  var _iDirectiveMap;
  get directiveMap => _iDirectiveMap != null ? _iDirectiveMap : _iDirectiveMap = inj.parent.getByKey(DirectiveMap_KEY);

  var _iNgBaseCss;
  get ngBaseCss => _iNgBaseCss != null ? _iNgBaseCss : _iNgBaseCss = inj.parent.getByKey(NgBaseCss_KEY);

  var _iNodeTreeSanitizer;
  get nodeTreeSanitizer => _iNodeTreeSanitizer != null ? _iNodeTreeSanitizer : _iNodeTreeSanitizer = inj.parent.getByKey(NodeTreeSanitizer_KEY);

  var _iWebPlatform;
  get webPlatform => _iWebPlatform != null ? _iWebPlatform : _iWebPlatform = inj.parent.getByKey(WebPlatform_KEY);

  var _iComponentCssRewriter;
  get componentCssRewriter => _iComponentCssRewriter != null ? _iComponentCssRewriter : _iComponentCssRewriter = inj.parent.getByKey(ComponentCssRewriter_KEY);

  var _iExpando;
  get expando => _iExpando != null ? _iExpando : _iExpando = inj.parent.getByKey(Expando_KEY);

  var _iExceptionHandler;
  get exceptionHandler => _iExceptionHandler != null ? _iExceptionHandler : _iExceptionHandler = inj.parent.getByKey(ExceptionHandler_KEY);

  var _iFormatterMap;
  get formatterMap => _iFormatterMap != null ? _iFormatterMap : _iFormatterMap = inj.parent.getByKey(FormatterMap_KEY);

  var _iNgControl;
  get ngControl => _iNgControl != null ? _iNgControl : _iNgControl = inj.parent.getByKey(NgControl_KEY);

  var _iInterpolate;
  get interpolate => _iInterpolate != null ? _iInterpolate : _iInterpolate = inj.parent.getByKey(Interpolate_KEY);
 

  final ngTrueValue = new NgTrueValue();
  final ngFalseValue = new NgFalseValue();

  void bindByKey(Key type, {dynamic toValue: _DEFAULT_VALUE,
      FactoryFn toFactory: _DEFAULT_VALUE, Type toImplementation,
      Type withAnnotation, Visibility visibility}) {

    if (withAnnotation != null) {
      throw "annotation not impl";
    }
    if (toValue != _DEFAULT_VALUE) {
      if (type.id == Element_KEY.id) {
        element = toValue;
        return;
      }
      if (type.id == NodeAttrs_KEY.id) {
        nodeAttrs = toValue;
        return;
      }
      if (type.id == View_KEY.id) {
        view = toValue;
        return;
      }
      if (type.id == Node_KEY.id) {
        node = toValue;
        return;
      }
      if (type.id == ViewFactory_KEY.id) {
        viewFactory = toValue;
        return;
      }
      if (type.id == ViewPort_KEY.id) {
        _iViewPort = toValue;
        useViewPort = true;
        return;
      }
      if (type.id == BoundViewFactory_KEY.id) {
        _iBoundViewFactory = toValue;
        useBoundViewFactory = true;
        return;
      }
      if (type.id == Scope_KEY.id) {
        _iScope = toValue;
        return;
      }
      if (type.id == TemplateLoader_KEY.id) {
        templateLoader = toValue;
        return;
      }
      if (type.id == ShadowRoot_KEY.id) {
        shadowRoot = toValue;
        return;
      }
      throw "Unknown value $type";
    }
    if (toFactory != _DEFAULT_VALUE) {
      if (type.id == ElementProbe_KEY.id) {
        factoryElementProbe = toFactory;
        return;
      }
      if (type.id == BoundViewFactory_KEY.id) {
        factoryBoundViewFactory = toFactory;
        return;
      }
      if (type.id == ViewPort_KEY.id) {
        factoryViewPort = toFactory;
        return;
      }
      if (type.id == NgInternalOptions_KEY.id) {
        factoryNgInternalOptions = toFactory;
        return;
      }
      if (type.id == TreeComponent_KEY.id) {
        factoryTreeComponent = toFactory;
        return;
      }
      if (type.id == TextMustache_KEY.id) {
        factoryTextMustache = toFactory;
        return;
      }
      throw "Unknown factory $type";
    }
    if (type.id == NgModel_KEY.id) {
      useNgModel = true;
      return;
    }
    if (type.id == NgElement_KEY.id) {
      useNgElement = true;
      return;
    }
    if (type.id == NgIf_KEY.id) {
      useNgIf = true;
      return;
    }
    if (type.id == AHref_KEY.id) {
      useAHref = true;
      return;
    }
    if (type.id == InputCheckbox_KEY.id) {
      useInputCheckbox = true;
      return;
    }
    if (type.id == NgInternalOptions_KEY.id) {
      useNgInternalOptions = true;
      return;
    }
    if (type.id == EventHandler_KEY.id) {
      useEventHandler = true;
      return;
    }
    if (type.id == TreeComponent_KEY.id) {
      useTreeComponent = true;
      return;
    }
    throw "Unknown type $type";
  }
}
