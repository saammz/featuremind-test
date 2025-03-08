const Env env = Env.kDev;

enum Env {
  kDev,
  kProd
}

const kBaseUrl = <Env, String>{
  Env.kDev: "",
  Env.kProd: ""
};

bool kDebugMode = env == Env.kDev;
